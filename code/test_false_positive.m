function bbox_1 = test_false_positive(bbox_1)
%Hack added- If Detector provides a bbox within bbox only keep the outer one
% A better training might help with better detections and then can do
% away with this hack

bbox_h = [];
for i = 1:size(bbox_1,1)
    first = bbox_1(i,:);
    ok = true;
    for j = 1:size(bbox_1,1)
        second = bbox_1(j,:);
        overlap_ratio = bboxOverlapRatio(first,second,'ratioType','Min');
        area_1 = first(3) * first(4);
        area_2 = second(3) * second(4);
        if overlap_ratio > 0.5 && area_1 < area_2
            ok = false;
        end
    end
    if ok
        bbox_h = [bbox_h;first];
    end
end

bbox_1 = bbox_h;
end