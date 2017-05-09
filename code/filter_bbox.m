function bbox = filter_bbox(bbox_1,bbox_2)
global max_area_bbox;
global min_area_bbox;
global min_bbox_ratio;
global max_bbox_ratio;
global bbox_dist_thresh;

bbox = [];
for i = 1 :size(bbox_1,1)
    area_1 = bbox_1(i,3) * bbox_1(i,4);
    cent_1 = [bbox_1(i,1) + bbox_1(i,3) / 2, bbox_1(i,2) + bbox_1(i,4) / 2];
    if area_1 > max_area_bbox || area_1 < min_area_bbox
        continue;
    end
    for j = 1:size(bbox_2,1)
        area_2 = bbox_2(j,3) * bbox_2(j,4);
        cent_2 = [bbox_2(j,1) + bbox_2(j,3) / 2, bbox_2(j,2) + bbox_2(j,4) / 2];
        if hypot((cent_2(1) - cent_1(1)), (cent_2(2) - cent_1(2))) < bbox_dist_thresh && ...
             (area_1 / area_2) > min_bbox_ratio && (area_1 / area_2) < max_bbox_ratio
         bbox = [bbox; bbox_1(i,:)];
        end
    end
end       
end