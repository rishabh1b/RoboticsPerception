function M = find_mser(im_roi, delta, maxarea, minarea, sz)
%Function to find MSER regions in an image. This essentially is a wrapper
% on vl_feat toolbox function vl_mser
%Input - im_roi -> input RGB image of type uint8
%      - delta -> tolerance parameter for stable regions in MSER
%      - maxarea -> ratio of area of stable region to the entire image. 
%                   ignore above this value
%      - minarea -> ratio of area of stable region to the entire image. 
%                   ignore below this value
%      -sz ->  size of the original image. 
% output - M -> BW image with MSER regions filled with value 1 
[r,~] = vl_mser(im_roi,'MinDiversity',0.7,...
                'MaxVariation',0.2,...
                'Delta',delta, 'DarkOnBright', 0, 'MaxArea', maxarea, 'MinArea', minarea ) ;
M = zeros(sz) ;
sAll = [];
for x=r'
 s = vl_erfill(im_roi,x) ;
 sAll = [sAll;s];
end
% Obtain the output in the original size image
M_roi = zeros(500, sz(2));
M_roi(sAll) = 1;
M(1:500,:) = M(1:500,:) + M_roi;
end