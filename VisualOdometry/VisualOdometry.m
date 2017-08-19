%% Get the Camera Parametes
image_dir = '..\input\Oxford_dataset\stereo\centre';
[fx, fy, cx, cy, ~, LUT] = ReadCameraModel(image_dir,'..\input\Oxford_dataset\model');
K = [fx 0 cx;0 fy cy; 0 0 1];
%% Init Pose
R_t = eye(3);
t_t = [0;0;0];
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
%% Extract feature descriptor
gray_prev_img = rgb2gray(rgb_prev_img);
pointsPrev = detectSURFFeatures(gray_prev_img);
[featuresPrev, pointsPrev] = extractFeatures(gray_prev_img,pointsPrev, 'Upright', true);
%% Set the Visualization window
loc_arr = [0,0];
figure(1)
subplot(2,1,1)
newimg = imresize(rgb_prev_img, [h w], 'nearest');
imshow(newimg)
g = subplot(2,1,2);
p = get(g,'position');
p(1) = p(1) * 1.75;
p(4) = p(4)*1.2;
p(3) = p(3) * 0.8;
set(g, 'position', p);
plot(-loc_arr(:,1), loc_arr(:,2)), xlabel('X'), ylabel('Z')
filename = sprintf('im_vo_%d.jpg',1);
output_folder = ('..\output\frames');
hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
%% Main Loop
for i = 2:numberOfImageFiles
    curr_file_name = fullfile(image_dir,cell2mat(curr_file_names(i)));
    curr_img = imread(curr_file_name);
    rgb_curr_img = demosaic(curr_img,'gbrg');
    rgb_curr_img = UndistortImage(rgb_curr_img, LUT);
    gray_curr_img = rgb2gray(rgb_curr_img);
    pointsCurr = detectSURFFeatures(gray_curr_img);
    [featuresCurr, pointsCurr] = extractFeatures(gray_curr_img,pointsCurr, 'Upright', true);

    indexPairs = matchFeatures(featuresPrev,featuresCurr) ;
    matchedPoints1 = pointsPrev(indexPairs(:,1),:);
    matchedPoints2 = pointsCurr(indexPairs(:,2),:);
    %figure(1); showMatchedFeatures(rgb_prev_img,rgb_curr_img,matchedPoints1,matchedPoints2);
    %legend('Image 1', 'Image 2')
    %% Compute the Fundamental Matrix using RANSAC
    F = computeFundamentalMatrixRANSAC(matchedPoints1, matchedPoints2);
    %% Get the Pose from Fundamental Matrix
    [Rset, Cset] = PoseFromFundamentalMatrix(F,K);
    [R, t] = disambiguateChoices(Cset, Rset);
    t_t = t_t + R_t * t;
    R_t = R_t * R;
    loc_arr = [loc_arr;[t_t(1),t_t(3)]];
    rs_img = imresize(rgb_curr_img, [h w], 'nearest');
    figure(1)
    subplot(2,1,1), imshow(rs_img)
    g = subplot(2,1,2);
    p = get(g,'position');
    p(1) = p(1) * 1.75;
    p(4) = p(4)* 1.2;
    p(3) = p(3) * 0.8;
    set(g, 'position', p);
    plot(-loc_arr(:,1), loc_arr(:,2)), drawnow
    filename = sprintf('im_vo_%d.jpg',i);
    % Uncomment For exporting a particular plot
    %hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
    %% Change for next iteration
    featuresPrev = featuresCurr;
    pointsPrev = pointsCurr;
end

