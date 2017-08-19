function coords =  get_bbox_coords(bbox)
coords = zeros(4,2);
coords(1,:) = [bbox(1), bbox(2)];
coords(2,:) = [bbox(1) + bbox(3), bbox(2)];
coords(3,:) = [bbox(1), bbox(2) + bbox(4)];
coords(4,:) = [bbox(1) + bbox(3), bbox(2) + bbox(4)];
end