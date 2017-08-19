% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Set the paths
frameid = 200;
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
mu = modelparams(1,1);
var = modelparams(1,2);
%var = 20.1726;
%%
im = imread(fullfilename);
[m, n, ~] = size(im);
% For Red
curr_R = double(reshape(im(:,:,1), [numel(im(:,:,1)),1]));
prob = normcdf(curr_R, mu, var);
prob = reshape(prob, [m, n]);
imtool(prob)
% For Green
% curr_G = double(reshape(im(:,:,2), [numel(im(:,:,2)),1]));
% prob = normcdf(curr_G, mu, var);
% prob = reshape(prob, [m, n]);
% imtool(prob)
%For Yellow
% im_y = (double(im(:,:,1)) + double(im(:,:,2))) ./ 2;
% curr_Y = reshape(im_y, [numel(im_y),1]);
% prob = normcdf(curr_Y, mu, var);
% prob = reshape(prob, [m, n]);
% imtool(prob)
%%
curr_bw = prob > 0.5;
figure
imshow(curr_bw)
%%
bw_biggest = false(size(curr_bw));
CC = bwconncomp(curr_bw);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
bw_biggest(CC.PixelIdxList{idx}) = true; 
struct = strel('disk', 25);
im_close = imclose(bw_biggest, struct);
figure,
imshow(bw_biggest); hold on;
B = bwboundaries(im_close);
pixels_needed = cell2mat(B(1));
figure
imshow(im)
hold on
[sorted_pixels,ind] = sort(pixels_needed);
pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];
pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
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
plot(xunit, yunit, 'linewidth', 2, 'Color','red');
%plot(pixels_needed(:,2),pixels_needed(:,1),'r', 'linewidth', 2)
