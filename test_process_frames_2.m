
%% Read a frame and extract the corners of the square
% D = dir([datafolder,'\*.jpg']);
% numOfFrames = length(D);
% fullfilename = fullfile(datafolder,D(1).name);
im = imread('Data/multipleTags/Frame 18.jpg');
imshow(im);
im_gray = rgb2gray(im);
image_size = size(im_gray);
label = segment(im);
%imtool(label);
%%
stats = regionprops(label, 'Area', 'Centroid');
black_img_1 = zeros(size(im_gray));
black_img_2 = zeros(size(im_gray));
black_img_3 = zeros(size(im_gray));

blackArray=cat(3,black_img_1,black_img_2,black_img_3);

%pastes the 3 images on to a seperate black screen
for i= 1:length(stats)
    if stats(i).Area > 17000
        %disp(i);
        mask = zeros(size(im_gray));
        mask(label==i)=1;
        blackArray(:,:,i)=im2double(im_gray).*mask;
        %figure, imshow(blackArray(:,:,i));
    end
end
%% loop
Id=[]; 
for k=1:3
    getRegionOfInterest_2(blackArray(:,:,k)); 
    im_bw_white= blackArray(:,:,k) > 0.9;
    label_2 = bwlabel(im_bw_white);
    stats_2 = regionprops(label_2, 'Area');
    if stats_2(1).Area < stats_2(2).Area
        internal_white = (label_2 == 1);
    else
        internal_white = (label_2 == 2);
    end
    im_bw_black = 1 - im_bw_white;
    im_bw_black(internal_white) = 1;
    label_3 = bwlabel(im_bw_black);
    stats_3 = regionprops(label_3, 'Area');
    if stats_3(1).Area > stats_3(2).Area
        im_bw_black(label_3 == 1) = 0;
    else
        im_bw_black(label_3 == 2) = 0;
    end
    [~, r, c] = harris(im_bw_black, 1, .04, 'N', 10, 'display', false);
    %imshow(im_bw_black);
    % remove false positive 
    true_corners = [c(1), r(1)];
    for j = 2:10
        false_positive = false;
        for i = 1:size(true_corners,1)
            if hypot((c(j) - true_corners(i,1)), r(j) - true_corners(i,2)) < 25
                false_positive = true;
                break;
            end
        end
        if ~false_positive
            true_corners = [true_corners;[c(j) r(j)]];
        end
        if size(true_corners,1) == 4
            break;
        end
    end
    
    square= true_corners;
    %rotate in clockwise
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
    %disp(square);
    im_clean = getCleanedFrontalTagImage(square, im_gray);
    [tag_id,right_positions] = getmarkeridandpositions(im_clean);
    % %% Plot the circles in the order of the upright Orientation
%     upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
%                        square(right_positions(3),:);square(right_positions(4),:)];
    
    upright_corners(:,:,k) = cat(1,[square(right_positions(1),:),square(right_positions(2),:),...
                       square(right_positions(3),:),square(right_positions(4),:)]);
    Id(k)=[tag_id];
end
%%
%figure, imshow(blackArray(:,:,k));
imshow(im);
hold on
plot(upright_corners(1,1,1),upright_corners(1,2,1),'ro','MarkerSize',10, 'MarkerFaceColor','r')
plot(upright_corners(1,3,1),upright_corners(1,4,1),'go','MarkerSize',10, 'MarkerFaceColor','g')
plot(upright_corners(1,5,1),upright_corners(1,6,1),'bo','MarkerSize',10, 'MarkerFaceColor','b')
plot(upright_corners(1,7,1),upright_corners(1,8,1),'yo','MarkerSize',10, 'MarkerFaceColor','y')

plot(upright_corners(1,1,2),upright_corners(1,2,2),'ro','MarkerSize',10, 'MarkerFaceColor','r')
plot(upright_corners(1,3,2),upright_corners(1,4,2),'go','MarkerSize',10, 'MarkerFaceColor','g')
plot(upright_corners(1,5,2),upright_corners(1,6,2),'bo','MarkerSize',10, 'MarkerFaceColor','b')
plot(upright_corners(1,7,2),upright_corners(1,8,2),'yo','MarkerSize',10, 'MarkerFaceColor','y')

plot(upright_corners(1,1,3),upright_corners(1,2,3),'ro','MarkerSize',10, 'MarkerFaceColor','r')
plot(upright_corners(1,3,3),upright_corners(1,4,3),'go','MarkerSize',10, 'MarkerFaceColor','g')
plot(upright_corners(1,5,3),upright_corners(1,6,3),'bo','MarkerSize',10, 'MarkerFaceColor','b')
plot(upright_corners(1,7,3),upright_corners(1,8,3),'yo','MarkerSize',10, 'MarkerFaceColor','y')
hold off
%% test to project lena
im_template = imread('Input/Lena.png');
template_y = size(im_template,1);
template_x = size(im_template,2);
%Padding of 5 pixels to avoid numerical errors
template_corners = [5 5; (template_x-5) 5;(template_x-5) (template_y-5);5 (template_y-5)];

im = imread('Data/multipleTags/Frame 19.jpg');
im_gray = rgb2gray(im);
image_size = size(im_gray);
label = segment(im);
%imshow(label);
stats = regionprops(label, 'Area', 'Centroid');
black_img_1 = zeros(size(im_gray));
black_img_2 = zeros(size(im_gray));
black_img_3 = zeros(size(im_gray));

blackArray=cat(3,black_img_1,black_img_2,black_img_3);

%pastes the 3 images on to a seperate black screen
for i= 1:length(stats)
    if stats(i).Area > 17000
        %disp(i);
        mask = zeros(size(im_gray));
        mask(label==i)=1;
        blackArray(:,:,i)=im2double(im_gray).*mask;
        %figure, imshow(blackArray(:,:,i));
    end
end

Id=[]; 
for k=1:3
    getRegionOfInterest_2(blackArray(:,:,k)); 
    im_bw_white= blackArray(:,:,k) > 0.9;
    label_2 = bwlabel(im_bw_white);
    stats_2 = regionprops(label_2, 'Area');
    if stats_2(1).Area < stats_2(2).Area
        internal_white = (label_2 == 1);
    else
        internal_white = (label_2 == 2);
    end
    im_bw_black = 1 - im_bw_white;
    im_bw_black(internal_white) = 1;
    label_3 = bwlabel(im_bw_black);
    stats_3 = regionprops(label_3, 'Area');
    if stats_3(1).Area > stats_3(2).Area
        im_bw_black(label_3 == 1) = 0;
    else
        im_bw_black(label_3 == 2) = 0;
    end
    [~, r, c] = harris(im_bw_black, 1, .04, 'N', 10, 'display', false);
    %imshow(im_bw_black);
    % remove false positive 
    true_corners = [c(1), r(1)];
    for j = 2:10
        false_positive = false;
        for i = 1:size(true_corners,1)
            if hypot((c(j) - true_corners(i,1)), r(j) - true_corners(i,2)) < 25
                false_positive = true;
                break;
            end
        end
        if ~false_positive
            true_corners = [true_corners;[c(j) r(j)]];
        end
        if size(true_corners,1) == 4
            break;
        end
    end
    
    square= true_corners;
    %rotate in clockwise
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
    %disp(square)
     
    square_corners(:,:,k)= cat(2,square(1,:),square(2,:),square(3,:)...
                                ,square(4,:));
                      
    %disp(square_corners)
    im_clean = getCleanedFrontalTagImage(square, im_gray);
    [tag_id,right_positions] = getmarkeridandpositions(im_clean);
    % %% Plot the circles in the order of the upright Orientation
%     upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
%                        square(right_positions(3),:);square(right_positions(4),:)];
    
    upright_corners(:,:,k) = cat(2,[square(right_positions(1),:),square(right_positions(2),:),...
                                   square(right_positions(3),:),square(right_positions(4),:)]);
                   
    Id(k)=[tag_id];
end

%% %project lena
square_1=[[square_corners(1,1,1),square_corners(1,2,1)];[square_corners(1,3,1)...
         ,square_corners(1,4,1)];[square_corners(1,5,1),square_corners(1,6,1)];...
         [square_corners(1,7,1),square_corners(1,8,1)]];

square_2=[[square_corners(1,1,2),square_corners(1,2,2)];[square_corners(1,3,2)...
         ,square_corners(1,4,2)];[square_corners(1,5,2),square_corners(1,6,2)];...
         [square_corners(1,7,2),square_corners(1,8,2)]];
     
square_3=[[square_corners(1,1,3),square_corners(1,2,3)];[square_corners(1,3,3)...
         ,square_corners(1,4,3)];[square_corners(1,5,3),square_corners(1,6,3)];...
         [square_corners(1,7,3),square_corners(1,8,3)]];
     
H = homography(square_1, template_corners); 
interior_pts_2 = calculate_interior_pts(image_size, square_1);
warped_points_2 = warp_points(H, interior_pts_2);
warped_points_2 = ceil(warped_points_2);
%%
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
imshow(template_proj_im)

% 2nd iteration
H_2 = homography(square_2, template_corners); 
interior_pts_2 = calculate_interior_pts(image_size, square_2);
warped_points_2 = warp_points(H_2, interior_pts_2);
warped_points_2 = ceil(warped_points_2);

ind_warped_points = sub2ind(size(im_template),warped_points_2(:,2),warped_points_2(:,1));
ind_video_im = sub2ind(size(im_gray),interior_pts_2(:,2), interior_pts_2(:,1));
template_proj_im = im;
for color=1:3
    curr_plane = im(:,:,color);
    curr_temp = im_template(:,:,color);
    curr_plane(ind_video_im) = curr_temp(ind_warped_points);
    template_proj_im(:,:,color) = curr_plane;
end
imshow(template_proj_im)

% 3rd iteration
H_3 = homography(square_3, template_corners); 
interior_pts_2 = calculate_interior_pts(image_size, square_3);
warped_points_2 = warp_points(H_3, interior_pts_2);
warped_points_2 = ceil(warped_points_2);

ind_warped_points = sub2ind(size(im_template),warped_points_2(:,2),warped_points_2(:,1));
ind_video_im = sub2ind(size(im_gray),interior_pts_2(:,2), interior_pts_2(:,1));
template_proj_im = im;
for color=1:3
    curr_plane = im(:,:,color);
    curr_temp = im_template(:,:,color);
    curr_plane(ind_video_im) = curr_temp(ind_warped_points);
    template_proj_im(:,:,color) = curr_plane;
end
imshow(template_proj_im)

%% Save the Current Image in the figure
% hgexport(gcf, fullfile(outputfolder, 'detected.jpg'), hgexport('factorystyle'), 'Format', 'jpeg');
% %% Create a temp directory to keep virtual cube images
% temp_output_folder = strcat(outputfolder, '/temp');
% if ~exist(temp_output_folder, 'dir')
%     mkdir (temp_output_folder);
% end
% %% Project the Lena Image
% outputVideo = VideoWriter(fullfile(outputfolder,'homography.mp4'),'MPEG-4');
% outputVideo.FrameRate = 30;
% open(outputVideo)
% 
% %% Start processing each frame
% im_template = imread('..\Input\Lena.png');
% for i = 1:numOfFrames
%     filename = sprintf('Frame %d.jpg', i);
%     fullfilename = fullfile(datafolder,filename);
%     im = imread(fullfilename);
%     im_gray = rgb2gray(im);
%     image_size = size(im_gray);
%     label = segment(im);
%     
%     stats = regionprops(label, 'Area', 'Centroid');
%     black_img_1 = zeros(size(im_gray));
%     black_img_2 = zeros(size(im_gray));
%     black_img_3 = zeros(size(im_gray));
% 
%     blackArray=cat(3,black_img_1,black_img_2,black_img_3);
%     %pastes the 3 images on to a seperate black screen
%     for i= 1:length(stats)
%         if stats(i).Area > 17000
%             disp(i);
%             mask = zeros(size(im_gray));
%             mask(label==i)=1;
%             blackArray(:,:,i)=im2double(im_gray).*mask;
%             %figure, imshow(blackArray(:,:,i));
%         end
%     end
%     
%     Id=[]; 
%     for k=1:3
%         getRegionOfInterest_2(blackArray(:,:,k)); 
%         im_bw_white= blackArray(:,:,k) > 0.9;
%         label_2 = bwlabel(im_bw_white);
%         stats_2 = regionprops(label_2, 'Area');
%         if stats_2(1).Area < stats_2(2).Area
%             internal_white = (label_2 == 1);
%         else
%             internal_white = (label_2 == 2);
%         end
%         im_bw_black = 1 - im_bw_white;
%         im_bw_black(internal_white) = 1;
%         label_3 = bwlabel(im_bw_black);
%         stats_3 = regionprops(label_3, 'Area');
%         if stats_3(1).Area > stats_3(2).Area
%             im_bw_black(label_3 == 1) = 0;
%         else
%             im_bw_black(label_3 == 2) = 0;
%         end
%         [~, r, c] = harris(im_bw_black, 1, .04, 'N', 10, 'display', false);
%         %imshow(im_bw_black);
%         % remove false positive 
%         true_corners = [c(1), r(1)];
%         for j = 2:10
%             false_positive = false;
%             for i = 1:size(true_corners,1)
%                 if hypot((c(j) - true_corners(i,1)), r(j) - true_corners(i,2)) < 25
%                     false_positive = true;
%                     break;
%                 end
%             end
%             if ~false_positive
%                 true_corners = [true_corners;[c(j) r(j)]];
%             end
%             if size(true_corners,1) == 4
%                 break;
%             end
%         end
% 
%         square= true_corners;
%         %rotate in clockwise
%         square_clock = square;
%         square_x = square(:,1);
%         [sorted_x,indx] = sort(square_x);
%         if square(indx(1),2) < square(indx(2),2)
%             square_clock(1,:) = [sorted_x(1), square(indx(1),2)];
%             square_clock(4,:) = [sorted_x(2), square(indx(2),2)];
%         else
%             square_clock(1,:) = [sorted_x(2), square(indx(2),2)];
%             square_clock(4,:) = [sorted_x(1), square(indx(1),2)];
%         end
%         if square(indx(3),2) < square(indx(4),2)
%             square_clock(2,:) = [sorted_x(3), square(indx(3),2)];
%             square_clock(3,:) = [sorted_x(4), square(indx(4),2)];
%         else
%             square_clock(2,:) = [sorted_x(4), square(indx(4),2)];
%             square_clock(3,:) = [sorted_x(3), square(indx(3),2)];
%         end
%         square = square_clock;
% 
%         im_clean = getCleanedFrontalTagImage(square, im_gray);
%         [tag_id,right_positions] = getmarkeridandpositions(im_clean);
%         % %% Plot the circles in the order of the upright Orientation
%     %     upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
%     %                        square(right_positions(3),:);square(right_positions(4),:)];
% 
%         upright_corners(:,:,k) = cat(1,[square(right_positions(1),:),square(right_positions(2),:),...
%                            square(right_positions(3),:),square(right_positions(4),:)]);
%         Id(k)=[tag_id];
%     end
%     %% Save the Current Image in the figure
%     hgexport(gcf, fullfile(outputfolder, 'detected.jpg'), hgexport('factorystyle'), 'Format', 'jpeg');
%     %% Create a temp directory to keep virtual cube images
%     temp_output_folder = strcat(outputfolder, '/temp');
%     if ~exist(temp_output_folder, 'dir')
%         mkdir (temp_output_folder);
%     end
%     %% Project the Lena Image
%     outputVideo = VideoWriter(fullfile(outputfolder,'homography.mp4'),'MPEG-4');
%     outputVideo.FrameRate = 30;
%     open(outputVideo)
%     %% Start processing each frame
%     im_template = imread('..\Input\Lena.png');
%     %% Project the Lena image onto the Tag
%     template_y = size(im_template,1);
%     template_x = size(im_template,2);
%     %Padding of 5 pixels to avoid numerical errors
%     template_corners = [5 5; (template_x-5) 5;(template_x-5) (template_y-5);5 (template_y-5)];
%     H = homography(square, template_corners);
%     interior_pts_2 = calculate_interior_pts(image_size, square);
%     warped_points_2 = warp_points(H, interior_pts_2);
%     warped_points_2 = ceil(warped_points_2);
%     % Perform Inverse Warping Lena->Tag
%     ind_warped_points = sub2ind(size(im_template),warped_points_2(:,2),warped_points_2(:,1));
%     ind_video_im = sub2ind(size(im_gray),interior_pts_2(:,2), interior_pts_2(:,1));
%     template_proj_im = im;
%     for color=1:3
%         curr_plane = im(:,:,color);
%         curr_temp = im_template(:,:,color);
%         curr_plane(ind_video_im) = curr_temp(ind_warped_points);
%         template_proj_im(:,:,color) = curr_plane;
%     end
%     %figure
%     %imshow(template_proj_im)
%     filename_lena = sprintf('../Output/test_lena_projection_process_frame_2_tag0/template_proj_im%d.jpg',i);
%     imwrite(template_proj_im,filename_lena,'jpg');
%     writeVideo(outputVideo,template_proj_im);
end
%% old code
% im= Frame13;
% im_gray = rgb2gray(im);
% image_size = size(im_gray);
% label = segment(im);
% stats = regionprops(label, 'Area', 'Centroid');
% mask = zeros(size(im_gray));
% mask(label == 1) = 1;
% segmented_page = im2double(im_gray) .* mask;
% im_bw_white  = segmented_page > 0.9;
% label_2 = bwlabel(im_bw_white);
% stats_2 = regionprops(label_2, 'Area');
% if stats_2(1).Area < stats_2(2).Area
%     internal_white = (label_2 == 1);
% else
%     internal_white = (label_2 == 2);
% end
% im_bw_black = 1 - im_bw_white;
% im_bw_black(internal_white) = 1;
% label_3 = bwlabel(im_bw_black);
% stats_3 = regionprops(label_3, 'Area');
% if stats_3(1).Area > stats_3(2).Area
%     im_bw_black(label_3 == 1) = 0;
% else
%     im_bw_black(label_3 == 2) = 0;
% end
% [~, r, c] = harris(im_bw_black, 1, .04, 'N', 10, 'display', true);
% imshow(im_bw_black);
% %
% %% Remove the False Positives
% true_corners = [c(1), r(1)];
% for j = 2:10
%     false_positive = false;
%     for i = 1:size(true_corners,1)
%         if hypot((c(j) - true_corners(i,1)), r(j) - true_corners(i,2)) < 25
%             false_positive = true;
%             break;
%         end
%     end
%     if ~false_positive
%         true_corners = [true_corners;[c(j) r(j)]];
%     end
%     if size(true_corners,1) == 4
%         break;
%     end
% end
% square = true_corners;
% %% Arrange the points in a clockwise manner
% square_clock = square;
% square_x = square(:,1);
% [sorted_x,indx] = sort(square_x);
% if square(indx(1),2) < square(indx(2),2)
%     square_clock(1,:) = [sorted_x(1), square(indx(1),2)];
%     square_clock(4,:) = [sorted_x(2), square(indx(2),2)];
% else
%     square_clock(1,:) = [sorted_x(2), square(indx(2),2)];
%     square_clock(4,:) = [sorted_x(1), square(indx(1),2)];
% end
% if square(indx(3),2) < square(indx(4),2)
%     square_clock(2,:) = [sorted_x(3), square(indx(3),2)];
%     square_clock(3,:) = [sorted_x(4), square(indx(4),2)];
% else
%     square_clock(2,:) = [sorted_x(4), square(indx(4),2)];
%     square_clock(3,:) = [sorted_x(3), square(indx(3),2)];
% end
% square = square_clock;
%% For testing and showing the detection of corners
% figure
% imshow(im_gray)
% hold on
% plot(square(:,1),square(:,2),'ys')
% imtool(im_gray)
%% Get the cleaned image and process it to get the tag_id and upright pos
% im_clean = getCleanedFrontalTagImage(square, im_gray);
% [tag_id,right_positions] = getmarkeridandpositions(im_clean);
% % %% Plot the circles in the order of the upright Orientation
% upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
%                    square(right_positions(3),:);square(right_positions(4),:)];
% imshow(im)
% hold on
% plot(upright_corners(1,1),upright_corners(1,2),'ro','MarkerSize',10, 'MarkerFaceColor','r')
% plot(upright_corners(2,1),upright_corners(2,2),'go','MarkerSize',10, 'MarkerFaceColor','g')
% plot(upright_corners(3,1),upright_corners(3,2),'bo','MarkerSize',10, 'MarkerFaceColor','b')
% plot(upright_corners(4,1),upright_corners(4,2),'yo','MarkerSize',10, 'MarkerFaceColor','y')
% %% Save the Current Image in the figure
% hgexport(gcf, fullfile(outputfolder, 'detected.jpg'), hgexport('factorystyle'), 'Format', 'jpeg');
% %% Create a temp directory to keep virtual cube images
% temp_output_folder = strcat(outputfolder, '/temp');
% if ~exist(temp_output_folder, 'dir')
%     mkdir (temp_output_folder);
% end
% %% Project the Lena Image
% outputVideo = VideoWriter(fullfile(outputfolder,'homography.mp4'),'MPEG-4');
% outputVideo.FrameRate = 30;
% open(outputVideo)
% %% Start processing each frame
% im_template = imread('..\Input\Lena.png');
% for i = 1:numOfFrames
%     filename = sprintf('Frame %d.jpg', i);
%     fullfilename = fullfile(datafolder,filename);
%     im = imread(fullfilename);
%     im_gray = rgb2gray(im);
%     image_size = size(im_gray);
%     label = segment(im);
%     stats = regionprops(label, 'Area', 'Centroid');
%     mask = zeros(size(im_gray));
%     mask(label == 1) = 1;
%     segmented_page = im2double(im_gray) .* mask;
%     im_bw_white  = segmented_page > 0.9;
%     label_2 = bwlabel(im_bw_white);
%     stats_2 = regionprops(label_2, 'Area');
%     if length(stats_2) ~= 2
%         continue;
%     end
%     if stats_2(1).Area < stats_2(2).Area
%         internal_white = (label_2 == 1);
%     else
%         internal_white = (label_2 == 2);
%     end
%     im_bw_black = 1 - im_bw_white;
%     im_bw_black(internal_white) = 1;
%     label_3 = bwlabel(im_bw_black);
%     stats_3 = regionprops(label_3, 'Area');
%     if length(stats_3) ~= 2
%         continue;
%     end
%     if stats_3(1).Area > stats_3(2).Area
%         im_bw_black(label_3 == 1) = 0;
%     else
%         im_bw_black(label_3 == 2) = 0;
%     end
%     Iblur = imgaussfilt(im_bw_black, 3);
%     %[~, r, c] = harris(im_bw_black, 1, .04, 'N', 10, 'display', false);
%     [~, r, c] = harris(Iblur, 1, .04, 'N', 10, 'display', false);
%     %% Remove the False Positives
%     true_corners = [c(1), r(1)];
%     for j = 2:10
%         false_positive = false;
%         for k = 1:size(true_corners,1)
%             if hypot((c(j) - true_corners(k,1)), r(j) - true_corners(k,2)) < 25
%                 false_positive = true;
%                 break;
%             end
%         end
%         if ~false_positive
%             true_corners = [true_corners;[c(j) r(j)]];
%         end
%         if size(true_corners,1) == 4
%             break;
%         end
%     end
%     square = true_corners;
%     %% Arrange the points in a clockwise manner
%     square_clock = square;
%     square_x = square(:,1);
%     [sorted_x,indx] = sort(square_x);
%     if square(indx(1),2) < square(indx(2),2)
%         square_clock(1,:) = [sorted_x(1), square(indx(1),2)];
%         square_clock(4,:) = [sorted_x(2), square(indx(2),2)];
%     else
%         square_clock(1,:) = [sorted_x(2), square(indx(2),2)];
%         square_clock(4,:) = [sorted_x(1), square(indx(1),2)];
%     end
%     if square(indx(3),2) < square(indx(4),2)
%         square_clock(2,:) = [sorted_x(3), square(indx(3),2)];
%         square_clock(3,:) = [sorted_x(4), square(indx(4),2)];
%     else
%         square_clock(2,:) = [sorted_x(4), square(indx(4),2)];
%         square_clock(3,:) = [sorted_x(3), square(indx(3),2)];
%     end
%     square = square_clock;
%     %% Project the Lena image onto the Tag
%     template_y = size(im_template,1);
%     template_x = size(im_template,2);
%     %Padding of 5 pixels to avoid numerical errors
%     template_corners = [5 5; (template_x-5) 5;(template_x-5) (template_y-5);5 (template_y-5)];
%     H = homography(square, template_corners);
%     interior_pts_2 = calculate_interior_pts(image_size, square);
%     warped_points_2 = warp_points(H, interior_pts_2);
%     warped_points_2 = ceil(warped_points_2);
%     % Perform Inverse Warping Lena->Tag
%     ind_warped_points = sub2ind(size(im_template),warped_points_2(:,2),warped_points_2(:,1));
%     ind_video_im = sub2ind(size(im_gray),interior_pts_2(:,2), interior_pts_2(:,1));
%     template_proj_im = im;
%     for color=1:3
%         curr_plane = im(:,:,color);
%         curr_temp = im_template(:,:,color);
%         curr_plane(ind_video_im) = curr_temp(ind_warped_points);
%         template_proj_im(:,:,color) = curr_plane;
%     end
%     %figure
%     %imshow(template_proj_im)
%     filename_lena = sprintf('../Output/test_lena_projection_process_frame_2_tag0/template_proj_im%d.jpg',i);
%     imwrite(template_proj_im,filename_lena,'jpg');
%     writeVideo(outputVideo,template_proj_im)
%     %% Projecting a virtual cube
% %     K = [700 -65 800
% %           0  710 850
% %           0   0     1];
% %     pr = [ 1 0 0;
% %            0 1 0 ];
% %     corners_tag = [0 0; 1 0; 1 1; 0 1];
% %     cube_corners_w = [corners_tag, zeros(4,1);
% %                       corners_tag, -ones(4,1)];
% %     %Only taking the x,y co-ordinates
% %     %inv(K) x upright_corners = [r1 r2 0|t] x corners_tag
% %     points_camera_frame = (pr*(K \ [upright_corners'; ones(1,4)]))';
% %     H = homography(corners_tag, points_camera_frame);
% %     virtual_cube(H,cube_corners_w,K,im);
% %     filename = sprintf('%d.jpg',i);
% %     hgexport(gcf, fullfile(temp_output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
% end
% close(outputVideo)
% %% Create AR Video
% % outputVideo = VideoWriter(fullfile(outputfolder,'virtual.mp4'),'MPEG-4');
% % outputVideo.FrameRate = 30;
% % open(outputVideo)
% % D = dir([temp_output_folder,'\*.jpg']);
% % numOfFrames = length(D);
% % for i = 1:numOfFrames
% %     curr_file = sprintf('%d.jpg',i);
% %     fullfilename = fullfile(temp_output_folder,curr_file);
% %     im = imread(fullfilename);
% %     writeVideo(outputVideo,im)
% % end
% % close(outputVideo)