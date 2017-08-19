function [ warped_pts ] = warp_points( H, sample_pts)
% warp_pts uses the homography to warp the
%points in sample_pts to points in the logo image
% Inputs:
%     video_pts: a 4x2 matrix of (x,y) coordinates of corners in the
%         video frame
%     logo_pts: a 4x2 matrix of (x,y) coordinates of corners in
%         the logo image
%     sample_pts: a nx2 matrix of (x,y) coordinates of points in the video
%         video that need to be warped to corresponding points in the
%         logo image
% Outputs:
%     warped_pts: a nx2 matrix of (x,y) coordinates of points obtained
%         after warping the sample_pts

curr_point = ones(3,1);
warped_pts = zeros(size(sample_pts,1),2);
for i = 1 : size(sample_pts,1)
    curr_point(1,1) = sample_pts(i,1);
    curr_point(2,1) = sample_pts(i,2);
    curr_point_logo = H * curr_point;
    curr_point_logo = curr_point_logo ./ curr_point_logo(3,1);
    curr_point_logo = curr_point_logo(1:2,1);
    warped_pts(i,:) = curr_point_logo';
end
end

