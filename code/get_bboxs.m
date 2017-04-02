function bbox = get_bboxs(im_erode, blobs_to_consider, min_blob_area, req_aspect_ratio)
S = regionprops(logical(im_erode), 'Area', 'BoundingBox');
allArea = [S.Area];
bbox = [];

if isempty(allArea)
   return;
end

[~,ind] = sort(allArea, 'descend'); 
iter = min(size(allArea,2), blobs_to_consider);
for j = 1:iter
   if allArea(ind(j)) < min_blob_area
       break;
   end
curr_bbox = S(ind(j)).BoundingBox;
% Get Rid of spurious blue noise and patches
if curr_bbox(4) / curr_bbox(3) < req_aspect_ratio || curr_bbox(3) / curr_bbox(4) < req_aspect_ratio
    continue;
else
    bbox = [bbox;curr_bbox];
end
end
end