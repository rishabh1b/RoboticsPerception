function red_mask = threshold_red(im)
im_hsv = rgb2hsv(im);
im_s = im_hsv(:,:,2);
im_v = im_hsv(:,:,3);
%imtool(im_v)
%imtool(im_s)
s_bin1 = im_s >= 0.5 & im_s <=0.9;
v_bin1 = im_v >= 0.20 & im_v <=0.65 ;
red_mask = s_bin1 & v_bin1;
end