%% Set the paths
%frameid = 20;
outputbwbasefilename = '../..Output/Part0/Frames/binary_';
outputsegbasefilename = '../..Output/Part1/Frames/output_';
testfolder = '../../Images/TestSet/Frames';
trial_output_path = '../../Output/Part1/';
% D = dir([testfolder,'\*.jpg']);
% numOfFrames = length(D);
%% Load the samples from the Training Set
load('Rsamples_comb.mat')
load('Ysamples_comb.mat')
load('Gsamples_1.mat')
% D = dir([testfolder,'\*.jpg']);
% numOfFrames = length(D);
%% Get the model params for Red, Yellow and Green
modelparams = estimate(Rsamples_comb,1);
mu_R = modelparams.mu;
sigma_R = modelparams.sigma;
modelparams = estimate(Ysamples_comb,2);
mu_Y = modelparams.mu;
sigma_Y = modelparams.sigma;
modelparams = estimate(Gsamples_1,3);
mu_G = modelparams.mu;
sigma_G = modelparams.sigma;
%% Other Parameters
struct_size = 25; %For closing operation on the buoy
thres_min_red_pixels = 100; % For concluding that there are no red pixels in the frame
thres_min_green_pixels = 100; % For concluding that there are no green pixels in the frame
thres_min_yellow_pixels = 80; % For concluding that there are no Yellow pixels in the frame
thres_prob_red = 0.4;
thres_prob_green = 0.5; 
thres_prob_yellow = 0.1; %0.4
max_radius_buoy = 30; % To prevent the circular contours to not represent the contours
max_radius_green_buoy = 20;
old_radius_window = 300;  % Inital guess, close to covering the entire image
old_centre_window = [240, 320];
for frameid = 1: 200
    %% Get the correct paths
    filename = sprintf('Frame %d.jpg',frameid);
    fullfilename = fullfile(testfolder, filename);
    %fullfilename_bw = strcat(outputbwbasefilename, filename);
    fullfilename_seg = strcat(outputsegbasefilename, filename);
    no_red_buoy = false;
    no_green_buoy = false;
    no_yellow_buoy = false;
    %% Read, Downsample the image to get an estimate on window of interest
    im = imread(fullfilename);
    im_d = double(im);
    [m,n,~] = size(im);
    numelems = numel(im(:,:,1));
    %% Get the samples from the entire image for Red Buoy Computation
    R = reshape(im_d(:,:,1),[numelems,1]);
    G = reshape(im_d(:,:,2),[numelems,1]);
    B = reshape(im_d(:,:,3),[numelems,1]);
     %% Calculate the score for Red buoy    
    R_3d = mvnpdf([R G B], mu_R, sigma_R);
    R_3d_norm = R_3d ./ max(R_3d);
    R_3d_norm_2d = reshape(R_3d_norm,[m,n]);
    %imtool(R_3d_norm_2d)
    %% Binarize Red Buoy Probability Map Image
    curr_bw_r = R_3d_norm_2d >= thres_prob_red;
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
            xunit_r(end+1) = xunit_r(1);
            yunit_r(end+1) = yunit_r(1);
            red_mask = poly2mask(xunit_r,yunit_r,m,n);
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
    Y_3d_norm_2d = zeros(m,n);
    Y_3d = mvnpdf([R G B], mu_Y, sigma_Y);
    Y_3d_norm = Y_3d ./ max(Y_3d);
    Y_3d_norm_2d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c) = reshape(Y_3d_norm, [subset_rows, subset_cols]);
    %imtool(Y_3d_norm_2d)
     %% Binarize the yellow Probability Map Image and mask out the red buoy
    curr_bw_y = Y_3d_norm_2d >= thres_prob_yellow;  
    if ~isempty(red_mask)
        curr_bw_y(red_mask == 1) = 0;
    end
     %% Obtain the Boundary Pixels for Yellow buoy from the BI
    pixels_needed = getBoundPixLargestBlob(curr_bw_y, thres_min_yellow_pixels, struct_size);
    %% Calculate a circular contour that fits the yellow buoy
    if ~isempty(pixels_needed) % Well, do it if there is any Yellow buoy
        [centre_y, radius_y] = getCentreAndRadius(pixels_needed);
        th = 0:pi/50:2*pi;
%         xunit_y = radius_y * cos(th) + centre_y(1);
%         yunit_y = radius_y * sin(th) + centre_y(2);
%         xunit_y(end+1) = xunit_y(1);
%         yunit_y(end+1) = yunit_y(1);
          xunit_y = pixels_needed(:,2);
          yunit_y = pixels_needed(:,1);
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
%     else
%         radius_window = 100;  % Revert to whole image
%         centre_window = [240, 320];
    end
    %% Calculate the score for Green Buoy - in the reduced window
    G_3d_norm_2d = zeros(m,n);
    G_3d = mvnpdf([R G B], mu_G, sigma_G);
    G_3d_norm = G_3d ./ max(G_3d);
    G_3d_norm_2d(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c) = reshape(G_3d_norm, [subset_rows, subset_cols]);
    %imtool(G_3d_norm_2d)
     %% Binarize the green Probability Map Image and mask out the red and yellow buoys
    curr_bw_g = G_3d_norm_2d >= thres_prob_green;
    if ~isempty(red_mask)
        curr_bw_g(red_mask == 1) = 0;
    end
    if ~isempty(yellow_mask == 1)
        curr_bw_g(yellow_mask == 1) = 0;
    end
     %% Obtain the Boundary Pixels for Green buoy from the BI
    pixels_needed = getBoundPixLargestBlob(curr_bw_g, thres_min_green_pixels, struct_size);
    %% Calculate a circular contour that fits the Green buoy
    if isempty(pixels_needed)
        no_green_buoy = true;
    else
        [centre_g, radius_g] = getCentreAndRadius(pixels_needed, true);
        %Sometimes Green Interferes with Yellow and Red. Due to lack of
        %training images green not identified completely
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
    if ~no_yellow_buoy
        plot(xunit_y, yunit_y, 'linewidth', 2, 'Color','yellow');
    end
    if ~no_green_buoy
        plot(xunit_g, yunit_g, 'linewidth', 2, 'Color','green');
    end
    hgexport(gcf, fullfile(trial_output_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end