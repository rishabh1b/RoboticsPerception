bw_biggest = false(size(curr_bw));
CC = bwconncomp(curr_bw);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
bw_biggest(CC.PixelIdxList{idx}) = true; 
struct = strel('disk', 25);
im_2 = imclose(bw_biggest, struct);
figure,
imshow(bw_biggest); hold on;
B = bwboundaries(im_2);
pixels_needed = cell2mat(B(1));
imshow(im)
hold on
plot(pixels_needed(:,2),pixels_needed(:,1),'r', 'linewidth', 2)
% struct = strel('disk', 6);
% struct_2 = strel('disk', 4);
% im_2 = imclose(curr_bw, struct_2);
% %imshow(im_2)
% im_3 = imopen(im_2, struct);

imtool(curr_bw)
%figure
%imshow(im_3)