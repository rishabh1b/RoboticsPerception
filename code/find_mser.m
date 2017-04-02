function M = find_mser(im_roi, delta, maxarea, minarea, sz)
% On a extracted region of interest - increases speed somewhat
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