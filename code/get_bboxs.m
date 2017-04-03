function bbox = get_bboxs(im_erode, blobs_to_consider, min_blob_area, req_aspect_ratio)
% function to filter out the bboxs in a BW image based on input parameters.
% Input - im_erode -> BW image, query properties in this BW image
%       - min_blob_area -> Ignore blobs less than this area
%       - blobs_to_consider -> Consider max only this much blobs area wise in the
%                              descending order
%       - req_aspect_ratio -> Ignore bounding box with aspect ratio less
%                             than this value. 
% Output - bbox -> blobs_to_consider x 4 array / max_blobs x 4 array,
%                  whichever is smaller
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