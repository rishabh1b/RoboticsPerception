% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Set the paths
%frameid = 30;
outputbwbasefilename = '../..Output/Part0/Frames/binary_';
outputsegbasefilename = '../..Output/Part0/Frames/output_';
testfolder = '../../Images/TestSet/Frames';
trial_path = '../../Output/Part1/';
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
%% Some other parameters
window_breadth = 40; % Initial guess,Should be little dynamic, based on the distance between centroid to top most pixel maybe?
for frameid = 173 : 176
    filename = sprintf('Frame %d.jpg',frameid);
    %filename_2 = sprintf('00%d.jpg',frameid);
    fullfilename = fullfile(testfolder, filename);
    fullfilename_bw = strcat(outputbwbasefilename, filename);
    fullfilename_seg = strcat(outputsegbasefilename, filename);
    %% Read, Downsample the image to get an estimate on window of interest
    im = imread(fullfilename);
    im_d = double(im);
    im_rz = imresize(im_d,0.2);
    [m,n,~] = size(im_rz);
    %% Extract a subset
    no_red_buoy = false;
    lower_lim_r = 25;
    upper_lim_r = 80;
    subset_R = im_rz(lower_lim_r:upper_lim_r,:,1);
    subset_G = im_rz(lower_lim_r:upper_lim_r,:,2);
    subset_B = im_rz(lower_lim_r:upper_lim_r,:,3);
    %% Calculate the probability
    num_elem = numel(subset_R);
    sample_downsampled = [reshape(subset_R, [num_elem,1]) reshape(subset_G, [num_elem,1]) reshape(subset_B, [num_elem,1])];
    prob_r = mvncdf(sample_downsampled, mu_R, sigma_R);
    %% Reshape to get a probability image
    prob_2D_r = zeros(m,n);
    rows = numel(lower_lim_r:upper_lim_r);
    prob_2D_r(lower_lim_r:upper_lim_r,:) = reshape(prob_r, [rows, n]);
    %imtool(prob_2D_r)
    %% Morphological processing
    curr_bw_R = prob_2D_r > 0.2; % Low probability value!
    % figure
    % imshow(curr_bw_R)
    curr_bw_R = imresize(curr_bw_R,5);
    % Get the pixel area with the largest number of pixels
    bw_biggest = false(size(curr_bw_R));
    CC = bwconncomp(curr_bw_R);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [red_pixels,idx] = max(numPixels);
    if red_pixels > 10  % If no red pixels, then skip
        bw_biggest(CC.PixelIdxList{idx}) = true; 
        struc = strel('disk', 25);
        im_close_R = imclose(bw_biggest, struc);
        %figure,
        %imshow(bw_biggest); hold on;
        % figure
        % imshow(im_close_R)
        B = bwboundaries(im_close_R);
        pixels_needed = cell2mat(B(1));
        %pixels_needed = pixels_needed * 4;
        %sz = size(pixels_needed,1);
        [sorted_pixels,ind] = sort(pixels_needed);
        pt1 = [sorted_pixels(1,2), sorted_pixels(1,1)];
        pt3 = [pixels_needed(ind(end,1), 2), sorted_pixels(end,1)];
        pt2 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
        [centre_window, ~] = calcCircle(pt1, pt2, pt3);
    else
        no_red_buoy = true;
    end
    %% Extract a subset for buoy extraction
    % Now that we have a good estimate of Red Buoy and a reduced window,
    % get contours of the Red buoy on the non-downsampled image. Ofcourse with
    % the reduced window size
    lower_lim_r = round(centre_window(2)) - window_breadth;
    upper_lim_r = round(centre_window(2)) + window_breadth;
    subset_R = im_d(lower_lim_r:upper_lim_r,:,1);
    subset_G = im_d(lower_lim_r:upper_lim_r,:,2);
    subset_B = im_d(lower_lim_r:upper_lim_r,:,3);
    %% Get the samples from this image
    num_elem = numel(subset_R);
    sample = [reshape(subset_R, [num_elem,1]) reshape(subset_G, [num_elem,1]) reshape(subset_B, [num_elem,1])];
    %% Calculate the probability for Red
    if ~no_red_buoy
        % Windowing speeds up the mvncdf!
        prob_R = mvncdf(sample, mu_R, sigma_R);
        %% Same Processes
        [m,n,~] = size(im_d);
        prob_2D_R = zeros(m,n);
        rows = numel(lower_lim_r:upper_lim_r);
        prob_2D_R(lower_lim_r:upper_lim_r,:) = reshape(prob_R, [rows, n]);
        %% Morphological processing
        curr_bw_R = prob_2D_R > 0.1;
    %     figure
    %     imshow(curr_bw_R)
        %% Get only Red Buoy
        bw_biggest = false(size(curr_bw_R));
        CC = bwconncomp(curr_bw_R);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        bw_biggest(CC.PixelIdxList{idx}) = true; 
        struc = strel('disk', 25);
        im_close_R = imclose(bw_biggest, struc);
        B = bwboundaries(im_close_R);
        pixels_needed = cell2mat(B(1));
    end
    %% Show the image with red boundary
    figure(1)
    imshow(im)
    hold on
    %%%%%%%%%%%%%LOGIC TO DRAW A CIRCLE%%%%%%%%%%%%%%%%%%%%
    if ~no_red_buoy
        [sorted_pixels,ind] = sort(pixels_needed);
        pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
        pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
        pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
        [centre, radius_window] = calcCircle(pt1, pt2, pt3);

        if (centre(1) < n - 50) %Ensure that circle will lie within image
            % figure
            % imshow(im)
            % hold on
            % plot(pt1(1),pt1(2),'*')
            % plot(pt2(1),pt2(2),'*')
            % plot(pt3(1),pt3(2),'*')

            th = 0:pi/50:2*pi;
            xunit = radius_window * cos(th) + centre(1);
            yunit = radius_window * sin(th) + centre(2);
            plot(xunit, yunit, 'linewidth', 2, 'Color','red');
        else
            % If not circle then plot just the boundary pixels 
            plot(pixels_needed(:,2),pixels_needed(:,1),'r', 'linewidth', 2)
            %Also get a rough estimate of the radius of the buoy to adjust
            %the window for yellow search
%             [sorted_pixels,ind] = sort(pixels_needed);
%             pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
%             pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
%             pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
%             [~, radius_window] = calcCircle(pt1, pt2, pt3);
        end
    end
    %% Readjust the window for yellow and green computation
    % Adjustment based on chnaging radius of the red buoy
    window_breadth = round(3 * radius_window);
    lower_lim_r = round(centre_window(2)) - window_breadth;
    upper_lim_r = round(centre_window(2)) + window_breadth;
    subset_R = im_d(lower_lim_r:upper_lim_r,:,1);
    subset_G = im_d(lower_lim_r:upper_lim_r,:,2);
    subset_B = im_d(lower_lim_r:upper_lim_r,:,3);
    %% Get the samples from this image
    num_elem = numel(subset_R);
    sample = [reshape(subset_R, [num_elem,1]) reshape(subset_G, [num_elem,1]) reshape(subset_B, [num_elem,1])];
    %% Now yellow, find the probabilites first
    prob_Y = mvncdf(sample, mu_Y, sigma_Y);
    %% Same Processes of forming probability image for Yellow
    [m,n,~] = size(im_d);
    prob_2D_Y = zeros(m,n);
    rows = numel(lower_lim_r:upper_lim_r);
    prob_2D_Y(lower_lim_r:upper_lim_r,:) = reshape(prob_Y, [rows, n]);
    %imtool(prob_2D_Y)
    %% Morphological processing
    curr_bw_Y = prob_2D_Y > 0.1;
    % Mask out the Red buoy
    curr_bw_Y(im_close_R == 1) = 0;
    %figure
    %imshow(curr_bw)
    %% Get only Yellow Buoy
    bw_biggest = false(size(curr_bw_Y));
    CC = bwconncomp(curr_bw_Y);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
    bw_biggest(CC.PixelIdxList{idx}) = true; 
    struc = strel('disk', 25);
    im_close_Y = imclose(bw_biggest, struc);
    B = bwboundaries(im_close_Y);
    pixels_needed = cell2mat(B(1));
    %% Show the image with Yellow boundary
    %%%%%%%%%%%%%LOGIC TO DRAW A CIRCLE%%%%%%%%%%%%%%%%%%%%
    [sorted_pixels,ind] = sort(pixels_needed);
    pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
    pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
    pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
    [centre, radius] = calcCircle(pt1, pt2, pt3);

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
    prob_G = mvncdf(sample, mu_G, sigma_G);
    %% Same Processes of forming probability image for Green
    [m,n,~] = size(im_d);
    prob_2D_G = zeros(m,n);
    rows = numel(lower_lim_r:upper_lim_r);
    prob_2D_G(lower_lim_r:upper_lim_r,:) = reshape(prob_G, [rows, n]);
    %% Morphological processing
    curr_bw_G = prob_2D_G > 0.85;
    % Get rid  of the Yellow and buoy noise
    curr_bw_G(im_close_Y == 1) = 0;
    curr_bw_G(im_close_R == 1) = 0;
%     figure
%     imshow(curr_bw_G)
    %% Get only Green Buoy
    bw_biggest = false(size(curr_bw_G));
    CC = bwconncomp(curr_bw_G);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [green_pixels,idx] = max(numPixels);
    if green_pixels < 10
        hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
        continue;
    elseif isempty(green_pixels)
        hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
        continue;
    end
    bw_biggest(CC.PixelIdxList{idx}) = true; 
    struc = strel('disk', 25);
    im_close_G = imclose(bw_biggest, struc);
    B = bwboundaries(im_close_G);
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

    % figure
    % imshow(im)
    % hold on
    % plot(pt1(1),pt1(2),'*')
    % plot(pt2(1),pt2(2),'*')
    % plot(pt3(1),pt3(2),'*')

    th = 0:pi/50:2*pi;
    xunit = radius * cos(th) + centre(1);
    yunit = radius * sin(th) + centre(2);
    %imshow(im), hold on
    plot(xunit, yunit, 'linewidth', 2, 'Color','green');
    %plot(pixels_needed(:,2),pixels_needed(:,1),'g', 'linewidth', 2)
    hgexport(gcf, fullfile(trial_path, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
