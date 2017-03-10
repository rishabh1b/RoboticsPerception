% This function is a clone of the process_frames function meant for quick
% testing for a frame
%% Read a frame and extract the corners of the square
datafolder = sprintf('../Data/Tag%d', 0);
D = dir([datafolder,'\*.jpg']);
numOfFrames = length(D);
fullfilename = fullfile(datafolder,D(70).name);
im = imread(fullfilename);
im_gray = rgb2gray(im);
%There are two versions of getRegionOfInterest
im_bw_black = getRegionOfInterest(im);
num_of_points = 20;
[~, r, c] = harris(im_bw_black, 1, .04, 'N', num_of_points, 'display', false);
square = remove_false_positives(c,r, num_of_points);
%% Arrange the points in a clockwise manner
square_clock = square;
square_x = square(:,1);
[sorted_x,indx] = sort(square_x);
if square(indx(1),2) < square(indx(2),2)
    square_clock(1,:) = [sorted_x(1), square(indx(1),2)];
    square_clock(4,:) = [sorted_x(2), square(indx(2),2)];
else
    square_clock(1,:) = [sorted_x(2), square(indx(2),2)];
    square_clock(4,:) = [sorted_x(1), square(indx(1),2)];
end
if square(indx(3),2) < square(indx(4),2)
    square_clock(2,:) = [sorted_x(3), square(indx(3),2)];
    square_clock(3,:) = [sorted_x(4), square(indx(4),2)];
else
    square_clock(2,:) = [sorted_x(4), square(indx(4),2)];
    square_clock(3,:) = [sorted_x(3), square(indx(3),2)];
end
square = square_clock;
%% For testing and showing the detection of corners
% figure
% imshow(im_gray)
% hold on
% plot(square(:,1),square(:,2),'ys')
% imtool(im_gray)
%% Get the cleaned image and process it to get the tag_id and upright pos
im_clean = getCleanedFrontalTagImage(square, im_gray);
[tag_id,right_positions] = getmarkeridandpositions(im_clean);
%% Plot the circles in the order of the upright Orientation
upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
                   square(right_positions(3),:);square(right_positions(4),:)];
imshow(im)
hold on
plot(upright_corners(1,1),upright_corners(1,2),'ro','MarkerSize',10, 'MarkerFaceColor','r')
plot(upright_corners(2,1),upright_corners(2,2),'go','MarkerSize',10, 'MarkerFaceColor','g')
plot(upright_corners(3,1),upright_corners(3,2),'bo','MarkerSize',10, 'MarkerFaceColor','b')
plot(upright_corners(4,1),upright_corners(4,2),'yo','MarkerSize',10, 'MarkerFaceColor','y')
%% Save the Current Image in the figure
%hgexport(gcf, fullfile(outputfolder, 'detected.jpg'), hgexport('factorystyle'), 'Format', 'jpeg');
%% Create a temp directory to keep virtual cube images
% temp_output_folder = strcat(outputfolder, '/temp');
% if ~exist(temp_output_folder, 'dir')
%     mkdir (temp_output_folder);
% end
%% Project the Lena Image
% outputVideo = VideoWriter(fullfile(outputfolder,'homography.mp4'),'MPEG-4');
% outputVideo.FrameRate = 30;
% open(outputVideo)
%% Start processing each frame
im_template = imread('..\Input\Lena.png');
template_y = size(im_template,1);
template_x = size(im_template,2);
%Padding of 5 pixels to avoid numerical errors
template_corners = [5 5; (template_x-5) 5;(template_x-5) (template_y-5);5 (template_y-5)];
for i = 161:161
    filename = sprintf('Frame %d.jpg', i);
    fullfilename = fullfile(datafolder,filename);
    im = imread(fullfilename);
    im_gray = rgb2gray(im);
    image_size = size(im_gray);
    %There are two version of getRegionOfInterest
    im_bw_black = getRegionOfInterest(im);
    Iblur = imgaussfilt(im_bw_black, 3);
    [~, r, c] = harris(Iblur, 1, .04, 'N', num_of_points, 'display', false);
    square = remove_false_positives(c,r, num_of_points);
    %% Arrange the points in a clockwise manner
    square_clock = square;
    square_x = square(:,1);
    [sorted_x,indx] = sort(square_x);
    if square(indx(1),2) < square(indx(2),2)
        square_clock(1,:) = [sorted_x(1), square(indx(1),2)];
        square_clock(4,:) = [sorted_x(2), square(indx(2),2)];
    else
        square_clock(1,:) = [sorted_x(2), square(indx(2),2)];
        square_clock(4,:) = [sorted_x(1), square(indx(1),2)];
    end
    if square(indx(3),2) < square(indx(4),2)
        square_clock(2,:) = [sorted_x(3), square(indx(3),2)];
        square_clock(3,:) = [sorted_x(4), square(indx(4),2)];
    else
        square_clock(2,:) = [sorted_x(4), square(indx(4),2)];
        square_clock(3,:) = [sorted_x(3), square(indx(3),2)];
    end
    square = square_clock;
    %% Project the Lena image onto the Tag
    H = homography(square, template_corners);
    interior_pts_2 = calculate_interior_pts(image_size, square);
    warped_points_2 = warp_points(H, interior_pts_2);
    warped_points_2 = ceil(warped_points_2);
    % Perform Inverse Warping Lena->Tag
    ind_warped_points = sub2ind(size(im_template),warped_points_2(:,2),warped_points_2(:,1));
    ind_video_im = sub2ind(size(im_gray),interior_pts_2(:,2), interior_pts_2(:,1));
    template_proj_im = im;
    for color=1:3
        curr_plane = im(:,:,color);
        curr_temp = im_template(:,:,color);
        curr_plane(ind_video_im) = curr_temp(ind_warped_points);
        template_proj_im(:,:,color) = curr_plane;
    end
    %figure
    %imshow(template_proj_im)
%     filename_lena = sprintf('../Output/test_lena_projection_process_frame_3_tag0/template_proj_im%d.jpg',i);
%     imwrite(template_proj_im,filename_lena,'jpg');
%     writeVideo(outputVideo,template_proj_im)
%% Plot the RGBY corners first
    im_clean = getCleanedFrontalTagImage(square, im_gray);
    [~,right_positions] = getmarkeridandpositions(im_clean);
    upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
                   square(right_positions(3),:);square(right_positions(4),:)];
    square = upright_corners;
    figure(2);
    %set(f,'Position',[0,0,1466,834]);
    imshow(im)
    hold on
    plot(upright_corners(1,1),upright_corners(1,2),'ro','MarkerSize',10, 'MarkerFaceColor','r')
    plot(upright_corners(2,1),upright_corners(2,2),'go','MarkerSize',10, 'MarkerFaceColor','g')
    plot(upright_corners(3,1),upright_corners(3,2),'bo','MarkerSize',10, 'MarkerFaceColor','b')
    plot(upright_corners(4,1),upright_corners(4,2),'yo','MarkerSize',10, 'MarkerFaceColor','y')
    %% Projecting a virtual cube
%    K = [629.30 0   330.766
%           0  635.53 251.004731
%           0   0     1];
%    K = [629.30 0  960
%           0  635.53 960
%           0   0     1];
   K =[1406.08415449821,0,0;
    2.20679787308599, 1417.99930662800,0;
    1014.13643417416, 566.347754321696,1]';

    corners_tag = [0 0; 1 0; 1 1; 0 1];
    cube_corners_w = [corners_tag, zeros(4,1);
                      corners_tag, -ones(4,1)];
    %Only taking the x,y co-ordinates
    %inv(K) x upright_corners = [r1 r2 0|t] x corners_tag
    %points_camera_frame = (pr*(K \ [upright_corners'; ones(1,4)]))';
    %H = homography(corners_tag, points_camera_frame);
    H = homography(corners_tag, square);
    virtual_cube(H,cube_corners_w,K,im);
    filename = sprintf('%d.jpg',i);
    %hgexport(gcf, fullfile(temp_output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
%sclose(outputVideo)
%% Create AR Video
% outputVideo = VideoWriter(fullfile(outputfolder,'virtual.mp4'),'MPEG-4');
% outputVideo.FrameRate = 30;
% open(outputVideo)
% D = dir([temp_output_folder,'\*.jpg']);
% numOfFrames = length(D);
% for i = 1:numOfFrames
%     curr_file = sprintf('%d.jpg',i);
%     fullfilename = fullfile(temp_output_folder,curr_file);
%     im = imread(fullfilename);
%     writeVideo(outputVideo,im)
% end
% close(outputVideo)