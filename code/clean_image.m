function im_erode = clean_image(im_final)
struct_2 = strel('rectangle', [3 3]); % [3 3]
im_dilate = imdilate(im_final, struct_2);
im_filtered = medfilt2(im_dilate, [5 5]); %[2 2]
struct = strel('rectangle', [5 5]);  %[2 2]
im_erode = imerode(im_filtered, struct);
im_erode = imfill(im_erode, 'holes');
end