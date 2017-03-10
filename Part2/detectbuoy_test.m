% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Set the paths
%outputbwbasefilename = '../..Output/Part2/Frames/binary_';
outputsegbasefilename = '../../Output/Part2/segmented/output_';
testfolder = '../../Images/TestSet/Frames';
D = dir([testfolder,'\*.jpg']);
numOfFrames = length(D);
%trial_output_path = '../../Output/Part2/segmented';
%% Load the samples from the Training Set
load('Rsamples_comb.mat')
load('Ysamples_comb.mat')
load('Gsamples_1.mat')
% D = dir([testfolder,'\*.jpg']);
% numOfFrames = length(D);
%% Get the GMM model for Red, Yellow and Green
gmmmodel_r = EM(2,Rsamples_comb);
gmmmodel_g = EM(2,Gsamples_1);
gmmmodel_y = EM(3,Ysamples_comb);
%% Other Parameters
struct_size = 25; %For closing operation on the buoy
thres_min_red_pixels = 50; % For concluding that there are no red pixels in the frame
thres_min_green_pixels = 50; % For concluding that there are no green pixels in the frame
thres_min_yellow_pixels = 20; % For concluding that there are no Yellow pixels in the frame
thres_prob_red = 0.2;
thres_prob_green = 0.05; %0.1
thres_prob_yellow = 0.01;
max_radius_buoy = 30; % To prevent the circular contours to not represent the contours
%% All Frames
%frameid = 120;
for frameid = 1 : numOfFrames
    filename = sprintf('Frame %d.jpg',frameid);
    %filename_2 = sprintf('00%d.jpg',frameid);
    fullfilename = fullfile(testfolder, filename);
    %fullfilename_bw = strcat(outputbwbasefilename, filename);
    %fullfilename_seg = strcat(outputsegbasefilename, filename);
    no_red_buoy = false;
    no_yellow_buoy = false;
    no_green_buoy = false;
     %% Read,
    im = imread(fullfilename);
    im_d = double(im);
    [m,n,~] = size(im);
    numelems = numel(im(:,:,1));
     %% Get the samples from the entire image for Red Buoy Computation
    R = reshape(im_d(:,:,1),[numelems,1]);
    G = reshape(im_d(:,:,2),[numelems,1]);
    B = reshape(im_d(:,:,3),[numelems,1]);
    %% Calculate the score for Red buoy    
    R_gmm = pdf(gmmmodel_r, [R G B]);
    R_gmm_norm = R_gmm ./ max(R_gmm);
    R_gmm_norm_2d = reshape(R_gmm_norm,[m,n]);
    %imtool(R_gmm_norm_2d)
    %% Binarize Red Buoy Probability Map Image
    curr_bw_r = R_gmm_norm_2d >= thres_prob_red;
    %% Obtain the Boundary Pixels for Red buoy from the BI
    pixels_needed = getBoundPixLargestBlob(curr_bw_r, thres_min_red_pixels, struct_size);
    %% Calculate a circular contour that fits the Red buoy
    if ~isempty(pixels_needed) % Well, do it if there is any red buoy
        [centre_window, radius_window] = getCentreAndRadius(pixels_needed, true);
         if radius_window == -1% Greater than threshold pixels but not quite detected
            radius_window = old_radius_window;
            centre_window = old_centre_window;
            no_red_buoy = true;
         else
            old_radius_window = radius_window; % Let's hope that we will be lucky in the first frame
            old_centre_window = centre_window;
        end
        if (centre_window(1) < (n - 40) && ~no_red_buoy && radius_window < max_radius_buoy) %Ensure that circle will lie within image
            th = 0:pi/50:2*pi;
            xunit_r = radius_window * cos(th) + centre_window(1);
            yunit_r = radius_window * sin(th) + centre_window(2);
            %plot(xunit_r, yunit_r, 'linewidth', 2, 'Color','red');
            %set(p_r, 'Visible', 'on')
            xunit_r(end+1) = xunit_r(1);
            yunit_r(end+1) = yunit_r(1);
            red_mask = poly2mask(xunit_r,yunit_r,m,n);
%             xunit_r = pixels_needed(:,2);
%             yunit_r = pixels_needed(:,1);
        elseif ~no_red_buoy
            xunit_r = pixels_needed(:,2);
            yunit_r = pixels_needed(:,1);
            red_mask = [];
        end
    else 
        no_red_buoy = true;
        red_mask = [];
    end
    %% Readjust the search window for yellow and green computation
    % Now that we know with some certainity the location of Red buoy,
    % exploit this information to narrow the window for the search of other
    % two buoys. The motivation to do this is - 1. It increases the speed
    % of the computation 2. Noise contaminates the yellow and green buoy
    % more than the red thus narrowing the window increases the probability
    % to find the other two buoys. Adjustment is dynamic depending on the
    % proximity to the buoy, the following factors are obtained looking at
    % co-ordinates across different frames
    if radius_window < 5
        radius_window = 200;
    end
    window_breadth = round(3 * radius_window);
    window_length = round(15 * 2 * radius_window);
    lower_lim_r = round(max([1, centre_window(2) - window_breadth]));
    upper_lim_r = round(min([m, centre_window(2) + window_breadth]));
    lower_lim_c = round(max([1, centre_window(1) - window_length]));
    upper_lim_c = round(min([n, centre_window(1) + window_length]));
    subset_rows = numel(lower_lim_r:upper_lim_r);
    subset_cols = numel(lower_lim_c:upper_lim_c);
    subset_r = im_d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c,1);
    subset_g = im_d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c,2);
    subset_b = im_d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c,3);
    num_elem = numel(subset_r);
    R = reshape(subset_r,[num_elem,1]);
    G = reshape(subset_g ,[num_elem,1]);
    B = reshape(subset_b,[num_elem,1]);
     %% Calculate the score for Yellow Buoy
    Y_gmm_norm_2d = zeros(m,n);
    Y_gmm = pdf(gmmmodel_y, [R G B]);
    Y_gmm_norm = Y_gmm ./ max(Y_gmm);
    Y_gmm_norm_2d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c) = reshape(Y_gmm_norm, [subset_rows, subset_cols]);
    %imtool(Y_gmm_norm_2d)
     %% Binarize the yellow Probability Map Image and mask out the red buoy
    curr_bw_y = Y_gmm_norm_2d >= thres_prob_yellow;  
    curr_bw_y(red_mask == 1) = 0;
     %% Obtain the Boundary Pixels for Yellow buoy from the BI
    pixels_needed = getBoundPixLargestBlob(curr_bw_y, thres_min_yellow_pixels, struct_size);
    %% Calculate a circular contour that fits the yellow buoy
    if ~isempty(pixels_needed) % Well, do it if there is any Yellow buoy
        [centre_y, radius_y] = getCentreAndRadius(pixels_needed);
        th = 0:pi/50:2*pi;
        xunit_y = radius_y * cos(th) + centre_y(1);
        yunit_y = radius_y * sin(th) + centre_y(2);
        %plot(xunit_y, yunit_y, 'linewidth', 2, 'Color','yellow');
        %set(p_r, 'Visible', 'on')
        xunit_y(end+1) = xunit_y(1);
        yunit_y(end+1) = yunit_y(1);
        yellow_mask = poly2mask(xunit_y,yunit_y,m,n);
        % HACK - Sometimes Red Interfers with the Yellow Samples
        if hypot((centre_window(2) - centre_y(2)), (centre_window(1) - centre_y(1))) < radius_y + 10
            no_red_buoy = true;
        end
    else
        no_yellow_buoy = true;
        yellow_mask = [];
    end
    if no_red_buoy && ~no_yellow_buoy % Change the window whose breadth is centered around this yellow buoy
        centre_window = centre_y;
        radius_window = radius_y;
    else
        radius_window = 300;  % Revert to whole image
        centre_window = [240, 320];
   end
    %% Calculate the score for Green Buoy - in the reduced window
    G_gmm_norm_2d = zeros(m,n);
    G_gmm = pdf(gmmmodel_g, [R G B]);
    G_gmm_norm = G_gmm ./ max(G_gmm);
    G_gmm_norm_2d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c) = reshape(G_gmm_norm, [subset_rows, subset_cols]);
    %imtool(Y_gmm_norm_2d)
     %% Binarize the green Probability Map Image and mask out the red and yellow buoys
    curr_bw_g = G_gmm_norm_2d >= thres_prob_green;
    curr_bw_g(red_mask == 1) = 0;
    curr_bw_g(yellow_mask == 1) = 0;
     %% Obtain the Boundary Pixels for Green buoy from the BI
    pixels_needed = getBoundPixLargestBlob(curr_bw_g, thres_min_green_pixels, struct_size);
    %% Calculate a circular contour that fits the Green buoy
    if isempty(pixels_needed)
        no_green_buoy = true;
    else
        [centre_g, radius_g] = getCentreAndRadius(pixels_needed);
        %Sometimes Green Interferes with Yellow
        if ~no_yellow_buoy && ((hypot((centre_g(2) - centre_y(2)), (centre_g(1) - centre_y(1))) < radius_y + 10) || ...
                (abs(centre_g(1) - centre_y(1)) < 10) || (abs(centre_g(1) - centre_window(1)) < 60))
            no_green_buoy = true;
        elseif ~no_red_buoy && (abs(centre_g(1) - centre_window(1)) < 60)
            no_green_buoy = true;
        else
            xunit_g = pixels_needed(:,2);
            yunit_g = pixels_needed(:,1);
        end
    end
    %% Plot all the contours
    figure(1)
    imshow(im), hold on
    if ~no_red_buoy
        plot(xunit_r, yunit_r, 'linewidth', 2, 'Color','red');
    end
    plot(xunit_y, yunit_y, 'linewidth', 2, 'Color','yellow');
    if ~no_green_buoy
        plot(xunit_g, yunit_g, 'linewidth', 2, 'Color','green');
    end
    output_filename = strcat(outputsegbasefilename, filename);
    hgexport(gcf, output_filename, hgexport('factorystyle'), 'Format', 'jpeg');
end
%% Generate a video sequence