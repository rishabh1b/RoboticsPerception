function [pixels_needed] = getBoundPixLargestBlob(curr_bw, thres, struct_size)
% getBoundPixLargestBlob finds the blob with largest number of pixels in a
% binary image and returns the boundary pixels of this blob. The
% implementation is for a circular buoy and uses a 'disk' structuring
% element to fill the holes in the circular blob
% Input - curr_bw -> Binary Image; thres
%         thres -> Returns boundary pixels only if the number of pixels in
%         the blob are greater than this threshold value
%         struct_size -> size of structuring element for the disk
% Output - pixels_needed -> An 2 X N array where each row corresponds to row
% and column position of the pixel in the matrix. 
pixels_needed = [];
bw_biggest = false(size(curr_bw));
CC = bwconncomp(curr_bw);
numPixels = cellfun(@numel,CC.PixelIdxList);
[pixels,idx] = max(numPixels);
if pixels > thres
    bw_biggest(CC.PixelIdxList{idx}) = true;
    struct = strel('disk', struct_size);
    im_close = imclose(bw_biggest, struct);
    %figure,
    %imshow(bw_biggest) %hold on;
    B = bwboundaries(im_close);
    pixels_needed = cell2mat(B(1));
end
end