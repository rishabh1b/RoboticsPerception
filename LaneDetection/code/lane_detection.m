function lane_detection()
% Script for finding lanes based on hough lines.
% Function plots the lane and creates a video
for i = 1:800
    curr_file = fullfile('..\Data\normal\', sprintf('Frame %d.jpg', i));
    im = imread(curr_file);
    im_r = im(:,:,1);
    im_g = im(:,:,2);
    im_b = im(:,:,3);
    %im_gray = rgb2gray(im);
    %im_denoise_gray = medfilt2(im_gray, [5 5]);
    %% Get the Region of interest through observation
    x=[539 680 1256 89];
    y=[419 417 708 716];
    m= 720; n=1280;

    mask = poly2mask(x, y, m, n);
    %mask_img=im2double(im_denoise_gray).*mask;
    imdouble= im2double(im);
    inew = imdouble.*repmat(mask,[1,1,3]); % Neat way of applying mask on each channel
    %% Convert to HSV space
    im_hsv = rgb2hsv(inew);
    im_hue = im_hsv(:,:,1);
    im_sat = im_hsv(:,:,2);
    im_val = im_hsv(:,:,3);
    %% Binarize each plane and show the Yellow Lane Mask
    h_bin = im_hue >= 0.09 & im_hue < 0.15;
    s_bin = im_sat >= 0.4 & im_sat <= 1;
    v_bin = im_val >= 0.8 & im_val < 1;
    yellow_lane_mask = h_bin & s_bin & v_bin;
    %% Binarize each plane and show the white lane mask
    h_bin_2 = im_hue >= 0.05 & im_hue < 0.2;
    s_bin_2 = im_sat >= 0.01 & im_sat <= 0.15;
    v_bin_2 = im_val >= 0.8 & im_val < 1;
    white_lane_mask = h_bin_2 & s_bin_2 & v_bin_2;
    %% Combine to obtain both the planes
    %im_lane = yellow_lane_mask + white_lane_mask; % For showinng purpose only
    %%%%%% End of Lane Masking
    %% Morphological Operation and Canny
    % Erosion is causing white lanes to disapper. Even with small structuring
    % elements. Also, it looks like it won't be necessary. Hence, skipping it
    % Split canny Edge detection for right and left lane
    canny_1= edge(yellow_lane_mask,'canny');
    canny_2 = edge(white_lane_mask, 'canny');
    %% Apply Hough Transform for left lane and extract a candidate for line
    [H,theta,rho] = hough(canny_1);
    P = houghpeaks(H,15,'threshold',ceil(0.2*max(H(:))));
    lines = houghlines(canny_1,theta,rho,P,'FillGap',20, 'MinLength',5);
    point_1s = zeros(length(lines),2);
    point_2s = zeros(length(lines),2);
    for k = 1:length(lines)
        point_1s(k,:) = [lines(k).point1];
        point_2s(k,:) = [lines(k).point2];
    end
    points = [point_1s;point_2s];
    [sorted_p1_y, ind] = sort(points(:,2));
    p1 = [points(ind(1),1),points(ind(end),1)];
    p2 = [sorted_p1_y(1),sorted_p1_y(end)];
    yellow_lane_direction = cross([p1(1), p2(1), 1], [p1(2), p2(2), 1]);
    yellow_lane_direction = yellow_lane_direction ./ sqrt(yellow_lane_direction(1)^2 + yellow_lane_direction(2)^2);
    theta_yellow = atan2(yellow_lane_direction(2), yellow_lane_direction(1));
    rho_yellow = yellow_lane_direction(3);
    l_y = [cos(theta_yellow), sin(theta_yellow), rho_yellow];
    %% Apply Hough Transform for right lane(white) and extract a candidate for line
    [H_r,theta_r,rho_r] = hough(canny_2);
    P_r = houghpeaks(H_r,15,'threshold',ceil(0.2*max(H_r(:)))); %0.2

    % Fill the gaps of Edges and set the Minimum length of a line
    lines_r = houghlines(canny_2,theta_r,rho_r,P_r,'FillGap',20, 'MinLength',5); %20
    point_1s_r = [];
    point_2s_r = [];
    for k = 1:length(lines_r)
        if lines_r(k).point1(1) > p1(1)  %Eliminates some white noise on the left of yellow lane
            point_1s_r = [point_1s_r;lines_r(k).point1];
            point_2s_r = [point_2s_r;lines_r(k).point2];
        end
    end
    if isempty(point_1s_r)
        continue;
    end
    if isempty(point_2s_r)
        continue;
    end
    points_r = [point_1s_r;point_2s_r];
    [sorted_p1_y_r, ind_r] = sort(points_r(:,2));
    p1_r = [points_r(ind_r(1),1),points_r(ind_r(end),1)];
    p2_r = [sorted_p1_y_r(1),sorted_p1_y_r(end)];
    white_lane_direction = cross([p1_r(1),p2_r(1),1],[p1_r(2),p2_r(2),1]);
    white_lane_direction = white_lane_direction ./(sqrt(white_lane_direction(1)^2 + white_lane_direction(2)^2));
    theta_mean = atan2(white_lane_direction(2), white_lane_direction(1));
    rhos_r_mean = white_lane_direction(3);
    %% Find the equation of line with slope zero passing through points on yellow lane
    l1 = [0, 1, -p2(1)];
    l2 = [cos(theta_mean), sin(theta_mean), rhos_r_mean];
    point_on_white_lane = cross(l1,l2);
    point_on_white_lane = point_on_white_lane ./ point_on_white_lane(3);
    l3 = [0, 1, -p2(2)];
    point_on_white_lane_2 = cross(l3,l2);
    point_on_white_lane_2 = point_on_white_lane_2 ./ point_on_white_lane_2(3);
    %% Find the Vanishing Point
    van_point = cross(l_y, l2);
    van_point = van_point ./ van_point(3);
    van_point_ratio = van_point(1) / size(im,2);
    if van_point_ratio > 0.47 && van_point_ratio < 0.485
        lane_direction = 'Left Curve Ahead';
    elseif van_point_ratio >= 0.485 && van_point_ratio <= 0.51
        lane_direction = 'Straight Road Ahead';
    else
        lane_direction = 'Right Curve Ahead';
    end
    %% Insert a Transparent green-coloured lane screen
    x = [p1(1) point_on_white_lane(1) point_on_white_lane_2(1) p1(2)];
    y = [p2(1) point_on_white_lane(2) point_on_white_lane_2(2) p2(2)];
    transp_mask = poly2mask(x,y,size(im,1), size(im,2));
    im_mod = im;
    im_g_new = uint8(zeros(size(im,1), size(im,2)));
    im_r(transp_mask == 1) = 0;
    im_g_new(transp_mask == 1) = 255;
    im_b(transp_mask == 1) = 0;
    im_mod(:,:,1) = im_r;
    im_g_2 = im_g;
    % Blend the images to get a transparent effect
    im_g_2(transp_mask == 1) = 0.8 * im_g(transp_mask == 1) + 0.2 * im_g_new(transp_mask == 1);
    im_mod(:,:,2) = im_g_2;
    im_mod(:,:,3) = im_b;
    %% Show the Lane
    figure(2)
    imshow(im_mod), hold on
    plot(p1,p2,'LineWidth',4,'Color','green');
    plot([point_on_white_lane(1),point_on_white_lane_2(1)],[point_on_white_lane(2), point_on_white_lane_2(2)],'LineWidth',4,'Color','green');
    %% Show the Vanishing Point
    plot(van_point(1), van_point(2), '.','Color','yellow', 'markersize', 10)
    text(180, 75, lane_direction,'horizontalAlignment', 'center', 'Color','red','FontSize',18)
    %% Save the File
    filename = sprintf('im_lane %d.jpg',i);
    output_folder = ('outputs');
    hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
%% Create a Video
CreateVideo(output_folder, 'lane_detection.mp4');
end