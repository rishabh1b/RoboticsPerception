function cent = get_centroid(bbox)
cent = [bbox(1,1) + bbox(1,3) / 2, bbox(1,2) + bbox(1,4) / 2];
end