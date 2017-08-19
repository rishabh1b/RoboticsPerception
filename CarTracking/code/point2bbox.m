function bbox = point2bbox(corners)
%Utility Function to convert a 4x2 mmatrix of co-ordinates to bounding box
bbox = [corners(1,1), corners(1,2), corners(2,1) - corners(1,1), corners(3,2) - corners(1,2)];
end