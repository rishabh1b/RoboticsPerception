function im_clean = getCleanedFrontalTagImage(vid_frame_corners, im_gray)
%% Compute the Homography between the marker and the image in the video frame
%Padding of 10 pixels each side of the array to avoid ceiling errors
front_facing_marker = [10 10; 210 10; 210 210; 10 210];
H = homography(vid_frame_corners, front_facing_marker);
image_size = size(im_gray);
%% Find the correspondences for each interior point
interior_pts = calculate_interior_pts(image_size,vid_frame_corners);
warped_points = warp_points(H, interior_pts);
warped_points = ceil(warped_points);
%% Replace the pixel value in the rectified image
curr_image = im2double(im_gray);
rect_image = zeros(220,220);
ind_rect_image = sub2ind([220,220],warped_points(:,2),warped_points(:,1));
ind_vid_image = sub2ind(image_size, interior_pts(:,2), interior_pts(:,1));
% For the case of grayscale only
rect_image(ind_rect_image) = curr_image(ind_vid_image);
%imshow(rect_image);
%% Perform some preprocessing operations to clean the rectified image
struct_elem = strel('square',10);
%Perform Dilation-Erosion to close the image
im_closed = imclose(rect_image, struct_elem);
im_bw = im_closed > 0.95;
%imshow(im_bw)
struct_elem_2 = strel('square',25);
im_clean = imclearborder(imopen(im_bw,struct_elem_2));
%imtool(im_clean)
end