% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Set the paths
frameid = 20;
outputbwbasefilename = '../..Output/Part0/Frames/binary_';
outputsegbasefilename = '../..Output/Part0/Frames/output_';
testfolder = '../../Images/TestSet/Frames';
% D = dir([testfolder,'\*.jpg']);
% numOfFrames = length(D);
filename = sprintf('Frame %d.jpg',frameid);
%filename_2 = sprintf('00%d.jpg',frameid);
fullfilename = fullfile(testfolder, filename);
fullfilename_bw = strcat(outputbwbasefilename, filename);
fullfilename_seg = strcat(outputsegbasefilename, filename);
%% Get the model params for now
mu = modelparams.mu;
sigma = modelparams.sigma;
%var = 20.1726;
%% Read
im = imread(fullfilename);
im_d = double(im);
[m,n,~] = size(im_d);
%% Extract a subset
lower_lim = 150;
upper_lim = 400;
subset_R = im_d(lower_lim:upper_lim,:,1);
subset_G = im_d(lower_lim:upper_lim,:,2);
subset_B = im_d(lower_lim:upper_lim,:,3);
%% Calculate the probability
%num_elem = numel(im_d(:,:,1));
num_elem = numel(subset_R);
%sample = [reshape(im_d(:,:,1), [num_elem,1]) reshape(im_d(:,:,2), [num_elem,1]) reshape(im_d(:,:,3), [num_elem,1])];
sample = [reshape(subset_R, [num_elem,1]) reshape(subset_G, [num_elem,1]) reshape(subset_B, [num_elem,1])];
prob = mvncdf(sample, mu, sigma);
%%
%prob = reshape(prob, [m, n]);
prob_all = zeros(m,n);
rows = numel(lower_lim:upper_lim);
prob_all(lower_lim:upper_lim,:) = reshape(prob, [rows, n]);
imtool(prob_all)
%imshow(prob > 0.6)
%% Morphological processing
curr_bw = prob_all > 0.1;
%figure
%imshow(curr_bw)
bw_biggest = false(size(curr_bw));
CC = bwconncomp(curr_bw);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = sort(numPixels, 'descend');
considered = idx(1:5);
%bw_biggest(CC.PixelIdxList{considered(5)}) = true;
for i = 1:5
    bw_biggest(CC.PixelIdxList{considered(i)}) = true;
end
imshow(bw_biggest)
props = regionprops(bw_biggest, 'MajorAxisLength', 'MinorAxisLength');
% structelem_2 = strel('disk',2);
% structelem = strel('disk',20);
% %bw_2 = imopen(curr_bw, structelem_2);
% bw_3 = imclose(curr_bw, structelem_2);
% figure
% imshow(bw_3)
%%
bw_biggest = false(size(curr_bw));
CC = bwconncomp(curr_bw);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
bw_biggest(CC.PixelIdxList{idx}) = true; 
struc = strel('disk', 25);
im_close = imclose(bw_biggest, struc);
figure,
imshow(bw_biggest); hold on;
figure
imshow(im_close)
B = bwboundaries(im_close);
pixels_needed = cell2mat(B(1));
%sz = size(pixels_needed,1);
[sorted_pixels,ind] = sort(pixels_needed);
pt1 = [sorted_pixels(1,2), sorted_pixels(1,1)];
pt3 = [pixels_needed(ind(end,1), 2), sorted_pixels(end,1)];
pt2 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
[centre, radius] = calcCircle(pt1, pt2, pt3);
figure
imshow(im)
hold on
plot(pt1(1),pt1(2),'*')
plot(pt2(1),pt2(2),'*')
plot(pt3(1),pt3(2),'*')

th = 0:pi/50:2*pi;
xunit = radius * cos(th) + centre(1);
yunit = radius * sin(th) + centre(2);
h = plot(xunit, yunit, 'linewidth', 2, 'Color','yellow');
xunit(end+1) = xunit(1);
yunit(end+1) = yunit(1);
figure
imshow(poly2mask(xunit,yunit,size(curr_bw,1),size(curr_bw,2)))
% plot(pixels_needed(:,2),pixels_needed(:,1),'r', 'linewidth', 2)
