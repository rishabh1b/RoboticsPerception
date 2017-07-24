function [marker_id, right_positions] = getmarkeridandpositions(im)
up_orient_angle = 0;
right_positions = [1,2,3,4];
top_left = [72,72];
top_right = [72,147];
bottom_left = [147,72];
if im(top_left(1),top_left(2)) == 1
    up_orient_angle = -180;
    right_positions(1) = 3;
    right_positions(3) = 1;
    right_positions(4) = 2;
    right_positions(2) = 4;
elseif im(top_right(1),top_right(2)) == 1
    up_orient_angle = -90;
    right_positions(2) = 1;
    right_positions(3) = 2;
    right_positions(4) = 3;
    right_positions(1) = 4;
elseif im(bottom_left(1), bottom_left(2)) == 1
    up_orient_angle = -270;
    right_positions(4) = 1;
    right_positions(1) = 2;
    right_positions(2) = 3;
    right_positions(3) = 4;
end
im_rot = imrotate(im, up_orient_angle);
imshow(im_rot)
centroids = zeros(4,2);
centroids(1,:) = [97, 97];
centroids(2,:) = [97, 122];
centroids(3,:) = [122, 122];
centroids(4,:) = [122, 97];
marker_id = 1 * round(im_rot(centroids(1,1), centroids(1,2))) +...
            2 * round(im_rot(centroids(2,1), centroids(2,2))) + ...
            4 * round(im_rot(centroids(3,1), centroids(3,2))) + ...
            8 * round(im_rot(centroids(4,1), centroids(4,2)));   
end