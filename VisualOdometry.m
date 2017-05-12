%% Get the Camera Parametes
image_dir = '..\input\Oxford_dataset\stereo\centre';
[fx, fy, cx, cy, ~, LUT] = ReadCameraModel(image_dir,'..\input\Oxford_dataset\model');
K = [fx 0 cx;0 fy cy; 0 0 1];
%% Init Pose
R_t = [1 0 0; 0 1 0; 0 0 1];
t_t = [0;0;0];
%% Set the paths
filePattern = sprintf('%s/*.png', image_dir);
baseFileNames = dir(filePattern);
curr_file_names = {baseFileNames.name};
numberOfImageFiles = length(baseFileNames);
% Create an empty viewSet object to manage the data associated with each view.
vSet = viewSet;
%% Get Hold of first frame
prev_file_name = fullfile(image_dir,cell2mat(curr_file_names(1)));
prev_img = imread(prev_file_name);
rgb_prev_img = demosaic(prev_img,'gbrg');
rgb_prev_img = UndistortImage(rgb_prev_img, LUT);
%% Extract feature descriptor
gray_prev_img = rgb2gray(rgb_prev_img);
pointsPrev = detectSURFFeatures(gray_prev_img);
[featuresPrev, pointsPrev] = extractFeatures(gray_prev_img,pointsPrev, 'Upright', true);

% Add the first view. Place the camera associated with the first view
% at the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, 'Points', pointsPrev, 'Orientation', eye(3),...
    'Location', [0 0 0]);

% Setup axes.
% figure(1)
% axis([-220, 50, -140, 20, -50, 300]);
% 
% % Set Y-axis to be vertical pointing down.
% view(gca, 3);
% set(gca, 'CameraUpVector', [0, -1, 0]);
% camorbit(gca, -120, 0, 'data', [0, 1, 0]);
% 
% grid on
% xlabel('X (cm)');
% ylabel('Y (cm)');
% zlabel('Z (cm)');
% 
% % Plot estimated camera pose.
% cameraSize = 7;
% camEstimated = plotCamera('Size', cameraSize, 'Location',...
%     vSet.Views.Location{1}, 'Orientation', vSet.Views.Orientation{1},...
%     'Color', 'g', 'Opacity', 0);

%Show the Features
%imshow(rgb_curr_img), hold on
%subset_features = pointsA(1:9:end);
%plot(subset_features)
%title('Subset of the detected features');
% Trial Plotting
loc_arr = [0,0,0];
for i = 2:100
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
    [relativeOrient, relativeLoc] = PoseFromFundamentalMatrix(F,K);
    %t_t = t_t + R_t * t;
    %R_t = R_t * R;
    %% Add the camera poses to the vset
    % Add the current view to the view set.
    vSet = addView(vSet, i, 'Points', pointsCurr);
    % Store the point matches between the previous and the current views.
    %vSet = addConnection(vSet, i-1, i, 'Matches', indexPairs(inlierIdx,:));
    vSet = addConnection(vSet, i-1, i);
     % Get the table containing the previous camera pose.
    prevPose = poses(vSet, i-1);
    prevOrientation = prevPose.Orientation{1};
    prevLocation    = prevPose.Location{1};

    % Compute the current camera pose in the global coordinate system
    % relative to the first view.
    orientation = prevOrientation * relativeOrient;
    location    = prevLocation + relativeLoc' * prevOrientation;
    vSet = updateView(vSet, i, 'Orientation', orientation, ...
        'Location', location);
    loc_arr = [loc_arr;location(1),location(2),location(3)];
    %% Change for next iteration
    featuresPrev = featuresCurr;
    pointsPrev = pointsCurr;
end
%% Show the Poses
%camPoses = poses(vSet);
%figure(1);
%helperPlotCameras(camPoses);

% Specify the viewing volume.
% loc1 = camPoses.Location{1};
% xlim([loc1(1)-5, loc1(1)+4]);
% ylim([loc1(2)-5, loc1(2)+4]);
% zlim([loc1(3)-1, loc1(3)+20]);
% camorbit(0, -30);
%% Show the Trajectory
figure(2)
plot3(loc_arr(:,1), loc_arr(:,2),loc_arr(:,3))
