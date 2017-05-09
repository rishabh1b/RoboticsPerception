function bbox = point2bbox(corners)
bbox = [corners(1,1), corners(1,2), corners(2,1) - corners(1,1), corners(3,2) - corners(1,2)];
end