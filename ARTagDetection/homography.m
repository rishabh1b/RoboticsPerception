function [ H ] = homography(video_pts, logo_pts)
% homography estimates the homography to transform each of the
% video_pts into the reference_image_pts
% Inputs:
%     video_pts: a 4x2 matrix of corner points in the video
%     logo_pts: a 4x2 matrix of logo points that correspond to video_pts
% Outputs:
%     H: a 3x3 homography matrix such that reference_image_pts ~ H*video_pts
A = zeros(8,9);
j = 1;
for i = 1:size(video_pts,1)
    [ax,ay] = constructA(video_pts(i,1),video_pts(i,2),logo_pts(i,1),logo_pts(i,2));
    A(j,:) = ax;
    j = j + 1;
    A(j,:) = ay;
    j = j + 1;
end
[~,~,V] = svd(A);  
h = V(:,size(V,2));
H = reshape(h,[3,3]);
H = H';

    function [ax,ay] = constructA(x_vid,y_vid,x_log,y_log)
        ax = [-x_vid -y_vid -1 0 0 0 (x_vid * x_log) (x_log * y_vid) x_log];
        ay = [0 0 0 -x_vid -y_vid -1 (x_vid * y_log) (y_vid * y_log) y_log];
    end
end

