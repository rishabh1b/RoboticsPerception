function im_r_usig = preprocess_red(im)
im_d = im2double(im);
im_c = imadjust(im_d, stretchlim(im_d));
im_b = im_c(:,:,3);
im_g = im_c(:,:,2);
im_r = im_c(:,:,1);
im_r = medfilt2(im_r, [3 3]); 
im_g = medfilt2(im_g, [3 3]); 
im_b = medfilt2(im_b, [3 3]); 
im_r = max(0,min((im_r - im_b), (im_r - im_g)) ./ (im_r + im_g + im_b));
im_r_usig = im2uint8(im_r);
end