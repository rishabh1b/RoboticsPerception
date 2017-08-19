% Script to obtain the animated plotting
clear all
load('trajectory_ransac_inliers.mat');
image_dir = '..\input\Oxford_dataset\stereo\centre';
[fx, fy, cx, cy, ~, LUT] = ReadCameraModel(image_dir,'..\input\Oxford_dataset\model');
%% Set the paths
filePattern = sprintf('%s/*.png', image_dir);
baseFileNames = dir(filePattern);
curr_file_names = {baseFileNames.name};
numberOfImageFiles = length(baseFileNames);
%% Get Hold of first frame
prev_file_name = fullfile(image_dir,cell2mat(curr_file_names(1)));
prev_img = imread(prev_file_name);
rgb_prev_img = demosaic(prev_img,'gbrg');
rgb_prev_img = UndistortImage(rgb_prev_img, LUT);
[h,w] = size(rgb_prev_img);
w = w*2.5/3;
%% Initialize the Video
outputfolder = ('..\output\frames');
filename = 'output_vo.mp4';
outputVideo = VideoWriter(fullfile(outputfolder,filename),'MPEG-4');
outputVideo.FrameRate = 30;
open(outputVideo);
%% Set the Visualization window
figure(1)
subplot(2,1,1)
newimg = imresize(rgb_prev_img, [h w], 'nearest');
imshow(newimg)
g = subplot(2,1,2);
p = get(g,'position');
p(1) = p(1) * 1.75;p(4) = p(4)*1.2;p(3) = p(3) * 0.8;
set(g, 'position', p);
plot(-loc_arr(1,1), loc_arr(1,2),'linewidth' , 2),title('Visual Odometry'), xlabel('X'), ylabel('Z')
xlim([-200 1200]),ylim([-200 900])
im_data = print('-RGBImage');
im_data = imresize(im_data, [1080 1920]);
writeVideo(outputVideo,im_data)
%% Main Loop
for i = 2:numberOfImageFiles
    curr_file_name = fullfile(image_dir,cell2mat(curr_file_names(i)));
    curr_img = imread(curr_file_name);
    rgb_curr_img = demosaic(curr_img,'gbrg');
    rgb_curr_img = UndistortImage(rgb_curr_img, LUT);
    rs_img = imresize(rgb_curr_img, [h w], 'nearest');
    figure(1)
    subplot(2,1,1), imshow(rs_img)
    g = subplot(2,1,2);
    p = get(g,'position');
    p(1) = p(1) * 1.75;
    p(4) = p(4)* 1.2;
    p(3) = p(3) * 0.8;
    set(g, 'position', p);
    plot(-loc_arr(1:i,1), loc_arr(1:i,2),'linewidth' , 2),title('Visual Odometry')
    xlim([-200 1200]),ylim([-200 900])
    xlabel('X'), ylabel('Z'), drawnow
    im_data = print('-RGBImage');
    im_data = imresize(im_data, [1080 1920]);
    writeVideo(outputVideo,im_data)
end
close(outputVideo)
    
