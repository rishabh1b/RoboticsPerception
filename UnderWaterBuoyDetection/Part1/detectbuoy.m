% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Get the samples for each colour
%colorsamples_r
%colorsamples_g
%colorsamples_y
%% Get the estimate of a single 3D Gaussian
modelparams_r = estimate(colorsamples_r,1);
modelparams_g = estimate(colorsamples_g,2);
modelparams_y = estimate(colorsamples_y,3);
mu_r = modelparams_r.mu;
sigma_r = modelparams_r.sigma;
mu_g = modelparams_g.mu;
sigma_g = modelparams_g.sigma;
mu_y = modelparams_y.mu;
sigma_y = modelparams_y.sigma;
%% Set the paths
frameid = 37;
outputbwbasefilename = '../..Output/Part0/Frames/binary_';
outputsegbasefilename = '../..Output/Part0/Frames/output_';
testfolder = '../../Images/TestSet/Frames';
filename = sprintf('Frame %d.jpg',frameid);
fullfilename = fullfile(testfolder, filename);
fullfilename_bw = strcat(outputbwbasefilename, filename);
fullfilename_seg = strcat(outputsegbasefilename, filename);
%% Detect Yellow Buoy
im = imread(fullfilename);
im_d = double(im);
[m,n,~] = size(im_d);
num_elem = numel(im_d(:,:,1));
sample = [reshape(im_d(:,:,1), [num_elem,1]) reshape(im_d(:,:,2), [num_elem,1]) reshape(im_d(:,:,3), [num_elem,1])];
prob = mvncdf(sample, mu_y, sigma_y);
prob = reshape(prob, [m, n]);
%imtool(prob)
%imshow(prob > 0.6)
%% Morphological processing for yellow
curr_bw_y = prob > 0.5;
%figure
%imshow(curr_bw)
bw_biggest = false(size(curr_bw_y));
CC = bwconncomp(curr_bw_y);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
bw_biggest(CC.PixelIdxList{idx}) = true; 
struc = strel('disk', 25);
im_close = imclose(bw_biggest, struc);
%figure,
%imshow(bw_biggest); hold on;
%figure
%imshow(im_close)
%% Contours for Yellow buoy
B = bwboundaries(im_close);
pixels_needed = cell2mat(B(1));
%sz = size(pixels_needed,1);
[sorted_pixels,ind] = sort(pixels_needed);
pt1 = [sorted_pixels(1,2), sorted_pixels(1,1)];
pt3 = [pixels_needed(ind(end,1), 2), sorted_pixels(end,1)];
pt2 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
if pt2(2) == pt3(2)
    pt2(2) = pt2(2) - 1;
end
[centre, radius] = calcCircle(pt1, pt2, pt3);

imshow(im)
hold on
th = 0:pi/50:2*pi;
xunit = radius * cos(th) + centre(1);
yunit = radius * sin(th) + centre(2);
plot(xunit, yunit, 'linewidth', 2, 'Color','yellow');
xunit(end+1) = xunit(1);
yunit(end+1) = yunit(1);
yellow_mask = poly2mask(xunit,yunit,size(curr_bw_y,1),size(curr_bw_y,2));
%% Detect Red Buoy
prob_R = mvncdf(sample, mu_r, sigma_r);
prob_R = reshape(prob_R, [m, n]);
imtool(prob_R)
%imshow(prob > 0.6)
%% Morphological processing for Red
curr_bw_r = prob_R > 0.5;
curr_bw_r(yellow_mask == 1) = 0;
% figure
% imshow(curr_bw_r)
bw_biggest = false(size(curr_bw_r));
CC = bwconncomp(curr_bw_r);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);

bw_biggest(CC.PixelIdxList{idx}) = true; 
% figure,
% imshow(bw_biggest);
struc = strel('disk', 25);
im_close = imclose(bw_biggest, struc);
% figure
% imshow(im_close)
%% Contours for the Red Buoy
B = bwboundaries(im_close);
pixels_needed = cell2mat(B(1));
%sz = size(pixels_needed,1);
[sorted_pixels,ind] = sort(pixels_needed);
pt1 = [sorted_pixels(1,2), sorted_pixels(1,1)];
pt3 = [pixels_needed(ind(end,1), 2), sorted_pixels(end,1)];
pt2 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
if pt2(2) == pt3(2)
    pt2(2) = pt2(2) - 1;
end
[centre, radius] = calcCircle(pt1, pt2, pt3);
th = 0:pi/50:2*pi;
xunit = radius * cos(th) + centre(1);
yunit = radius * sin(th) + centre(2);
plot(xunit, yunit, 'linewidth', 2, 'Color','Red');
%% Detect Green Buoy
prob_G = mvncdf(sample, mu_g, sigma_g);
prob_G = reshape(prob_G, [m, n]);
imtool(prob_G)
%imshow(prob > 0.6)
%% Morphological processing for Green Buoy
curr_bw_g = prob_G > 0.5;
curr_bw_g(yellow_mask == 1) = 0;
figure
imshow(curr_bw_g)
bw_biggest = false(size(curr_bw_g));
CC = bwconncomp(curr_bw_g);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
bw_biggest(CC.PixelIdxList{idx}) = true; 
% figure,
% imshow(bw_biggest);
struc = strel('disk', 25);
im_close = imclose(bw_biggest, struc);
% figure
% imshow(im_close)
%% Contours for Green buoy
B = bwboundaries(im_close);
pixels_needed = cell2mat(B(1));
%sz = size(pixels_needed,1);
[sorted_pixels,ind] = sort(pixels_needed);
pt1 = [sorted_pixels(1,2), sorted_pixels(1,1)];
pt3 = [pixels_needed(ind(end,1), 2), sorted_pixels(end,1)];
pt2 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
if pt2(2) == pt3(2)
    pt2(2) = pt2(2) - 1;
end
[centre, radius] = calcCircle(pt1, pt2, pt3);

% figure
% imshow(im)
% hold on
% plot(pt1(1),pt1(2),'*')
% plot(pt2(1),pt2(2),'*')
% plot(pt3(1),pt3(2),'*')

th = 0:pi/50:2*pi;
xunit = radius * cos(th) + centre(1);
yunit = radius * sin(th) + centre(2);
xunit(end+1) = xunit(1);
yunit(end+1) = yunit(1);
imshow(im)
hold on
h = plot(xunit, yunit, 'linewidth', 2, 'Color','green');