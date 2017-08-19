function detectBuoy(frameid, modelparams)
% frameid -> frame id of a particular test image
% modelparams -> 3 x 2 matrix for the learned mu and var values for RED,
% GREEN and YELLOW(in that order)
%% Set the paths
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
curr_R = double(reshape(im(:,:,1), [numel(im(:,:,1)),1]));
prob_R = normcdf(curr_R, mu, var);
prob_R = reshape(prob_R, [m, n]);

curr_bw = prob_R > 0.5;
bw_biggest = false(size(curr_bw));
CC = bwconncomp(curr_bw);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
bw_biggest(CC.PixelIdxList{idx}) = true; 
struct = strel('disk', 25);
im_close = imclose(bw_biggest, struct);
%figure,
%imshow(bw_biggest); hold on;
B = bwboundaries(im_close);
pixels_needed = cell2mat(B(1));
imshow(im)
hold on
plot(pixels_needed(:,2),pixels_needed(:,1),'r', 'linewidth', 2)
end
