function blue_mask = threshold_blue(im)
im_hsv = rgb2hsv(im);
im_s = im_hsv(:,:,2);
im_v = im_hsv(:,:,3);
im_s_bw = im_s >= 0.45 & im_s <= 0.8; % decreased lower bound from 0.6 to 0.35 to 0.45
im_v_bw = im_v >= 0.35 & im_v <= 1; % Could be done away with
blue_mask = im_s_bw & im_v_bw;
end