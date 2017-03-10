% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Set the paths
outputbwbasefilename = '../..Output/Part0/Frames/binary_';
outputsegbasefilename = '../..Output/Part0/Frames/output_';
testfolder = '../../Images/TestSet/Frames';
trial_path = '../../Output/Part0/segmented';
% D = dir([testfolder,'\*.jpg']);
% numOfFrames = length(D);
%% Get the samples
load('Ysamples_comb.mat')
load('Rsamples_comb.mat')
load('Gsamples_1.mat')
%% Get the model params for now
modelparams = estimate(Rsamples_comb,1);
mu_r = modelparams(1,1);
var_r = modelparams(1,2);
modelparams = estimate(Gsamples_1,2);
mu_g = modelparams(1,1);
var_g = modelparams(1,2);
modelparams = estimate(Ysamples_comb,3);
mu_y = modelparams(1,1);
var_y = modelparams(1,2);
window_breadth = 40;
for frameid = 1:150
    %% Get the File handle
    filename = sprintf('Frame %d.jpg',frameid);
    fullfilename = fullfile(testfolder, filename);
    fullfilename_bw = strcat(outputbwbasefilename, filename);
    fullfilename_seg = strcat(outputsegbasefilename, filename);
    %%
    im = imread(fullfilename);
    [m, n, ~] = size(im);
    no_red_buoy = false;
    %% Where is my Red Buoy?
    % For Red
    curr_R = double(reshape(im(:,:,1), [numel(im(:,:,1)),1]));
    prob = normcdf(curr_R, mu_r, var_r);
    prob = reshape(prob, [m, n]);
    %imtool(prob)
    %% Binarize and perform morphological operations
    curr_bw = prob > 0.45;
    %curr_bw = prob > 0.5;
    %figure
    %imshow(curr_bw)
    %%
    bw_biggest = false(size(curr_bw));
    CC = bwconncomp(curr_bw);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [red_pixels,idx] = max(numPixels);
    if red_pixels > 30 % Ensure that we have a Red Buoy
        bw_biggest(CC.PixelIdxList{idx}) = true; 
        struct = strel('disk', 25);
        im_close_r = imclose(bw_biggest, struct);
        %figure,
        %imshow(bw_biggest); hold on;
        B = bwboundaries(im_close_r);
        pixels_needed = cell2mat(B(1));
        figure(1)
        imshow(im)
        hold on
        [sorted_pixels,ind] = sort(pixels_needed);
        pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
        pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
        pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
        [centre_window, radius_window] = calcCircle(pt1, pt2, pt3);
        if radius_window == -1
            radius_window = old_radius_window;
            centre_window = old_centre_window;
            no_red_buoy = true;
        else
            old_radius_window = radius_window;
            old_centre_window = centre_window;
        end
        if (centre_window(1) < (n - 10) && ~no_red_buoy) %Ensure that circle will lie within image
            th = 0:pi/50:2*pi;
            xunit = radius_window * cos(th) + centre_window(1);
            yunit = radius_window * sin(th) + centre_window(2);
            p_r = plot(xunit, yunit, 'linewidth', 2, 'Color','red');
            set(p_r, 'Visible', 'on')
            xunit(end+1) = xunit(1);
            yunit(end+1) = yunit(1);
            red_mask = poly2mask(xunit,yunit,size(curr_bw,1),size(curr_bw,2));
%         else
%             % If not lying within the image then plot just the boundary pixels 
%             plot(pixels_needed(:,2),pixels_needed(:,1),'r', 'linewidth', 2)
        end
    else 
        no_red_buoy = true;
    end
    %% Readjust the window for yellow and green computation
    % Adjustment based on changing radius of the red buoy
    window_breadth = round(3 * radius_window);
    window_length = round(9 * 2 * radius_window);
    lower_lim_r = round(centre_window(2)) - window_breadth;
    upper_lim_r = round(centre_window(2)) + window_breadth;
    lower_lim_c = round(max([1, centre_window(1) - window_length]));
    upper_lim_c = round(min([n, centre_window(1) + window_length]));
%     subset_r = im(lower_lim_r:upper_lim_r,:,1);
%     subset_g = im(lower_lim_r:upper_lim_r,:,2);
    subset_r = im(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c,1);
    subset_g = im(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c,2);
    %subset_b = im(lower_lim_r:upper_lim_r,:,3);
    num_elem = numel(subset_r);
    sample = (double(reshape(subset_r, [num_elem,1])) + double(reshape(subset_g, [num_elem,1]))) ./ 2;
    %% Now find the Probability for yellow
    prob_y = normcdf(sample, mu_y, var_y);
    %imtool(prob_Y)
    prob_2D_y = zeros(m,n);
    rows = numel(lower_lim_r:upper_lim_r);
    cols = numel(lower_lim_c:upper_lim_c);
    %prob_2D_y(lower_lim_r:upper_lim_r,:) = reshape(prob_y, [rows, n]);
    prob_2D_y(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c) = reshape(prob_y, [rows, cols]);
    curr_bw_y = prob_2D_y > 0.3;
    % Mask out the Red buoy
    %curr_bw_y(im_close_r == 1) = 0;
    curr_bw_y(red_mask == 1) = 0;
    %figure
    %imshow(curr_bw)
    %% Get only Yellow Buoy
    bw_biggest = false(size(curr_bw_y));
    CC = bwconncomp(curr_bw_y);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
    bw_biggest(CC.PixelIdxList{idx}) = true; 
    struc = strel('disk', 25);
    im_close_y = imclose(bw_biggest, struc);
    B = bwboundaries(im_close_y);
    pixels_needed = cell2mat(B(1));
    %% Show the image with Yellow boundary
    %%%%%%%%%%%%%LOGIC TO DRAW A CIRCLE%%%%%%%%%%%%%%%%%%%%
    [sorted_pixels,ind] = sort(pixels_needed);
    pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
    pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
    pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
    [centre, radius] = calcCircle(pt1, pt2, pt3);
    if radius > radius_window && hypot((centre_window(2) - centre(2)), (centre_window(1) - centre(1))) < (radius_window + 20)
        delete(p_r);
    end
    % figure
    % imshow(im)
    % hold on
    % plot(pt1(1),pt1(2),'*')
    % plot(pt2(1),pt2(2),'*')
    % plot(pt3(1),pt3(2),'*')

    th = 0:pi/50:2*pi;
    xunit = radius * cos(th) + centre(1);
    yunit = radius * sin(th) + centre(2);
    plot(xunit, yunit, 'linewidth', 2, 'Color','yellow');
    % xunit(end+1) = xunit(1);
    % yunit(end+1) = yunit(1);
    %figure
    %imshow(poly2mask(xunit,yunit,size(curr_bw,1),size(curr_bw,2)))
    % plot(pixels_needed(:,2),pixels_needed(:,1),'y', 'linewidth', 2)
    if no_red_buoy % Change the window whose breadth is centered around this yellow buoy
        centre_window = centre;
        radius_window = radius;
    end
    %% Now Green, find the probabilites first
    prob_g = normcdf(sample, mu_g, var_g);
    %% Same Processes of forming probability image for Green
    prob_2D_g = zeros(m,n);
    rows = numel(lower_lim_r:upper_lim_r);
    cols = numel(lower_lim_c:upper_lim_c);
    %prob_2D_g(lower_lim_r:upper_lim_r,:) = reshape(prob_g, [rows, n]);
    prob_2D_g(lower_lim_r:upper_lim_r,lower_lim_c:upper_lim_c) = reshape(prob_g, [rows, cols]);
    %% Morphological processing
    curr_bw_g = prob_2D_g > 0.5;
    % Get rid  of the Yellow and red buoy noise
    curr_bw_g(im_close_y == 1) = 0;
    curr_bw_g(im_close_r == 1) = 0;
    %figure
    %imshow(curr_bw_G)
    %% Get only Green Buoy
    bw_biggest = false(size(curr_bw_g));
    CC = bwconncomp(curr_bw_g);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [green_pixels,idx] = max(numPixels);
    if green_pixels < 50
        hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
        continue;
    elseif isempty(green_pixels)
        hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
        continue;
    end
    bw_biggest(CC.PixelIdxList{idx}) = true; 
    struc = strel('disk', 25);
    im_close_g = imclose(bw_biggest, struc);
    B = bwboundaries(im_close_g);
    pixels_needed = cell2mat(B(1));
    %% Show the image with Green boundary
    [sorted_pixels,ind] = sort(pixels_needed);
    pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
    pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
    pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
    if pt2(2) == pt3(2)
        pt2(2) = pt2(2) - 1;
    end
    [centre, radius] = calcCircle(pt1, pt2, pt3);

    th = 0:pi/50:2*pi;
    xunit = radius * cos(th) + centre(1);
    yunit = radius * sin(th) + centre(2);
    if hypot((centre_window(2) - centre(2)), (centre_window(1) - centre(1))) < radius_window
        hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
        continue;
    end
    %imshow(im), hold on
    plot(xunit, yunit, 'linewidth', 2, 'Color','green');
    %plot(pixels_needed(:,2),pixels_needed(:,1),'g', 'linewidth', 2)
    hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end

