% This will test the robustness of the mask across each frame.
% Current approach will focus on the use of Hough Lines directly on the 
% image provided. That is let's skip homography for now
%% Get a Test Image and denoise
for i = 600:600
    curr_file = fullfile('..\..\Data\normal\', sprintf('Frame %d.jpg', i));
    im = imread(curr_file);
    im_gray = rgb2gray(im);
    im_denoise_gray = medfilt2(im_gray, [5 5]);
    %% Get the Region of interest through observation
    x=[539 680 1256 89];
    y=[419 417 708 716];
    m= 720; n=1280;

    mask = poly2mask(x, y, m, n);
    mask_img=im2double(im_denoise_gray).*mask;
    imdouble= im2double(im);
    inew = imdouble.*repmat(mask,[1,1,3]); % Neat way of applying mask on each channel
    %% Convert to HSV space
    %imtool(im_denoise_gray)
    im_hsv = rgb2hsv(inew);
    im_hue = im_hsv(:,:,1);
    im_sat = im_hsv(:,:,2);
    im_val = im_hsv(:,:,3);
    %im_denoise_sat = medfilt2(im_sat, [5 5]);
    %imtool(im_hue)
    %imtool(im_sat)
    %imtool(im_val)
    %imshow(im_gray)
    %% Binarize each plane and show the Yellow Lane Mask
    h_bin = im_hue >= 0.09 & im_hue < 0.15;
    s_bin = im_sat >= 0.4 & im_sat <= 1;
    v_bin = im_val >= 0.8 & im_val < 1;
    yellow_lane_mask = h_bin & s_bin & v_bin;
    %imtool(yellow_lane_mask)
    %% Binarize each plane and show the white lane mask
    h_bin_2 = im_hue >= 0.05 & im_hue < 0.2;
    s_bin_2 = im_sat >= 0.01 & im_sat <= 0.15;
    v_bin_2 = im_val >= 0.8 & im_val < 1;
    white_lane_mask = h_bin_2 & s_bin_2 & v_bin_2;
    %imtool(white_lane_mask)
    %% Combine to obtain both the planes
    im_lane = yellow_lane_mask + white_lane_mask;
    figure(1)
    imshow(im_lane)
    filename = sprintf('im_lane %d.jpg',i);
    debug_output_folder = ('lane_masks');
    hgexport(gcf, fullfile(debug_output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
    %imtool(im_lane)
    %% Morphological Operation and Canny
    %bw1 = bwareaopen(im_lane,10); % adjust the pixel value based on the hough output
    %se = strel('disk',1);
    %erodedBW = imerode(im_lane, se);
    %imtool(erodedBW)
    %apply canny

    % Erosion is causing white lanes to disapper. Even with small structuring
    % elements
    % Split canny Edge detection for right and left lane
    canny_1= edge(yellow_lane_mask,'canny');
    canny_2 = edge(white_lane_mask, 'canny');
    %figure
    %imshow(canny_2);
    %% Apply Hough Transform for left lane and extract a candidate for line
    [H,theta,rho] = hough(canny_1);
    P = houghpeaks(H,15,'threshold',ceil(0.2*max(H(:))));
    %x = theta(P(:,2));
    %y = rho(P(:,1));
    % Fill the gaps of Edges and set the Minimum length of a line
    lines = houghlines(canny_1,theta,rho,P,'FillGap',20, 'MinLength',5);
    figure(2)
    imshow(im), hold on
    %max_len = 0;
    rhos = zeros(length(lines),1);
    thetas = zeros(length(lines),1);
    point_1s = zeros(length(lines),2);
    point_2s = zeros(length(lines),2);
    for k = 1:length(lines)
        rhos(k) = lines(k).rho;
        theta(k) = lines(k).theta;
        point_1s(k,:) = [lines(k).point1];
        point_2s(k,:) = [lines(k).point2];
        %xy = [lines(k).point1; lines(k).point2];
    end
    points = [point_1s;point_2s];
    [sorted_p1_y, ind] = sort(points(:,2));
    p1 = [points(ind(1),1),points(ind(end),1)];
    p2 = [sorted_p1_y(1),sorted_p1_y(end)];
    plot(p1,p2,'LineWidth',4,'Color','green');
    % Plot beginnings and ends of lines
    %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','green');
    %% Apply Hough Transform for left lane and extract a candidate for line
    [H_r,theta_r,rho_r] = hough(canny_2);
    P_r = houghpeaks(H_r,15,'threshold',ceil(0.2*max(H_r(:))));

    % Fill the gaps of Edges and set the Minimum length of a line
    lines_r = houghlines(canny_2,theta_r,rho_r,P_r,'FillGap',20, 'MinLength',5);
    %imshow(im), hold on
    %max_len = 0;
    rhos_r = zeros(length(lines_r),1);
    thetas_r = zeros(length(lines_r),1);
    point_1s_r = zeros(length(lines_r),2);
    point_2s_r = zeros(length(lines_r),2);
    for k = 1:length(lines_r)
        rhos_r(k) = lines_r(k).rho;
        theta_r(k) = lines_r(k).theta;
        point_1s_r(k,:) = [lines_r(k).point1];
        point_2s_r(k,:) = [lines_r(k).point2];
    end
    points_r = [point_1s_r;point_2s_r];
    [sorted_p1_y_r, ind_r] = sort(points_r(:,2));
    p1_r = [points_r(ind_r(1),1),points_r(ind_r(end),1)];
    p2_r = [sorted_p1_y_r(1),sorted_p1_y_r(end)];
    plot(p1_r,p2_r,'LineWidth',4,'Color','green');
    % Plot beginnings and ends of lines
    %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','green');

    hold off
    %%%%%% End of Lane Masking
end
%%% Following approach relied on Sobel - Not being used anymore
%% Edge Detection
% Edge Results not exciting in the saturation plane
%BW = edge(im_denoise, 'Sobel');
%imshow(BW);
% BW_2 = edge(im_denoise_gray, 'Sobel');
% %figure
% %imshow(BW_2)
% BW_3 = edge(im_denoise_gray, 'Canny');
% figure
% imshow(BW_3)
% %% Yellow Lane Mask
% yellow_lane = yellow_lane_mask & BW_3;
% imtool(yellow_lane)
% %% Edge Detection with only X-Gradient Sobel Operator
% edge_filter_x = [1 0 -1; 2 0 -2; 1 0 -1];
% edge_filter_y = [1 2 1;0 0 0;-1 -2 -1];
% output = conv2(im_denoise_gray, edge_filter_x);
% %imtool(output > 180)
% output_2 = output > 150;
% yellow_lane_2 = yellow_lane_mask & double(output_2(1:720,1:1280));
% white_lane = white_lane_mask & BW_3 ;%double(output_2(1:720,1:1280));
% imtool(yellow_lane_2)
% imtool(white_lane)
% %% Thicken the yellow Lane
% struct = strel('rectangle', [5 5]);
% yellow_lane_bumped = imdilate(yellow_lane_2, struct);
% imtool(yellow_lane_bumped)
% %% Show the yellow Lane
% im_r = im(:,:,1);
% im_g = im(:,:,2);
% im_b = im(:,:,3);
% im_r(yellow_lane_bumped == 1) = 0;
% im_g(yellow_lane_bumped == 1) = 255;
% im_b(yellow_lane_bumped == 1) = 0;
% im_new = im;
% im_new(:,:,1) = im_r;
% im_new(:,:,2) = im_g;
% im_new(:,:,3) = im_b;
% imtool(im_new)
% %% Hough
% [H,T,R] = hough(yellow_lane_2);
% %P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
% P  = houghpeaks(H,1);
% lines = houghlines(yellow_lane_2,T,R,P,'FillGap',10);
% figure
% imshow(im)
% hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',6,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end