function im_b_usig = preprocess_blue(im)
% Function to denoise, improve contrast and normalize it suitably for blue
% sign identification
% Input -> im -> RGB uint8 image
% Output -> im_b_usig -> processed grayscale image for the blue channel of
%          the type uint8
im_d = im2double(im);
im_c = imadjust(im_d, stretchlim(im_d));
im_b = im_c(:,:,3);
im_b = medfilt2(im_b, [3 3]); 
im_b = max(0,(im_b - im_c(:,:,1)) ./ (im_c(:,:,1) + im_c(:,:,2) + im_c(:,:,3)));
im_b_usig = im2uint8(im_b);
end