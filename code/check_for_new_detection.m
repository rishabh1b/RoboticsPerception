function prev_bbox = check_for_new_detection(bbox, prev_bbox)
global bbox_exist;
global car_count;
global overlap_thresh;

sz_1 = size(bbox,1);
sz_2 = size(prev_bbox.bbox,1);
new_bbox = [];
for i=1:sz_1
    cent_1 = get_centroid(bbox(i,:));
    isnew = true;
    for j=1:sz_2
        cent_2 = get_centroid(prev_bbox.bbox(j,:));
        overlap_ratio = bboxOverlapRatio(bbox(i,:),prev_bbox.bbox(j,:));
        if hypot((cent_2(2) - cent_1(2)), (cent_2(1) - cent_1(1))) < bbox_exist || ...
               overlap_ratio > overlap_thresh 
            isnew = false;
            break;
        end
    end
    if isnew    
        new_bbox = [new_bbox;bbox(i,:)];
    end
end
new_sz = sz_2+size(new_bbox,1);
j = 1;
for i = (sz_2+1):new_sz
    prev_bbox.bbox(i,:) = new_bbox(j,:);
    prev_bbox.color(i,:) = randi(255,1,3);
    prev_bbox.num(i) = car_count;
    car_count = car_count + 1;
    j = j + 1;
end

end