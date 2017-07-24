function virtual_cube(H, render_points, K, ~)
% Estimate position and orientation with respect to a set of 4 points on
% the tag
% Inputs:
%    H - the computed homography from the corners in the image
%    render_points - size (N x 3) matrix of world points to project
%    K - size (3 x 3) calibration matrix for the camera
% Outputs: 
%    Plot of cube on the current figure

%% Extract the pose from the homography
B_tild = (K \ H);
if det(B_tild) < 0
    B = -B_tild;
else
    B = B_tild;
end
lambda = inv((norm(K \ H(:,1)) + norm(K \ H(:,2))) / 2);
r1 = lambda.* B(:,1);
r2 = lambda.* B(:,2);
r3 = cross(r1,r2);
R = [r1 r2 r3];
t = lambda .* B(:,3);
%% Project the point in 2D from 3D(homogeneous)
rend_points_homog = [render_points';ones(1,size(render_points,1))];
proj_points_homog = (K * [R t] * rend_points_homog)';

%% Get the 2D co-ordinates.
lambda = proj_points_homog(:,3);
proj_points = proj_points_homog(:,1:2) ./ [lambda lambda] ;
%% Plot the cube on the image
pts_ind = [1,2, 2,3, 3,4, 4,1, 5,6, 6,7, 7,8, 8,5, 1,5, 2,6, 3,7, 4,8];
dr = proj_points(pts_ind,:);
dr = round(dr);
%figure(2)
% image(im)
%hold on;
num_pts = size(dr,1);
for j = 1:2:num_pts
    line([dr(j,1), dr(j+1,1)],[dr(j,2), dr(j+1,2)],'Color',[.7 .5 0],'LineWidth',2);
end
hold off;
end