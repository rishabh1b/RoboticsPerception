% Script to track Cars from a video sequence
%% Some Parameters Defined
N = 30; % Number of frames after which detector should be called again 30 initially
global bbox_dist_thresh;
global min_bbox_ratio;
global max_bbox_ratio;
global max_area_bbox;
global min_area_bbox;
global bbox_exist;
global car_count;
global overlap_thresh;
global min_aspect_ratio_thresh;
global max_aspect_ratio_thresh;

bbox_dist_thresh = 10;
min_bbox_ratio = 0.7;
max_bbox_ratio = 1.3;
max_area_bbox = 100 * 100;
min_area_bbox = 30 * 30;
bbox_exist = 10;
car_count = 1;
overlap_thresh = 0.2;
min_aspect_ratio_thresh = 0.9;
max_aspect_ratio_thresh = 1.4;
% Define Region of Interest to minimize false positives
roi_row = 250; 
roi_col = 50;
%% Initialize the bbox structs
field_1 = 'bbox';
field_2 = 'color';
field_3 = 'num';
value_1 = {[]};
prev_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
curr_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
%% First Images
inpFramesPath = '..\input\simple';
outputFramesPath = '..\output\simple\frames';
second_frame = 'Frame 1.jpg';
first_frame = 'Frame 2.jpg';
second_file = fullfile(inpFramesPath, second_frame);
first_file = fullfile(inpFramesPath, first_frame);
first_img = imread(first_file);
second_img = imread(second_file);
%% ROI
x = roi_col;
y = roi_row;
width = size(first_img,2) - 2*roi_col;
height = size(first_img,1)-roi_row;
roi = [x,y,width,height];

%% Detection init
detector = vision.CascadeObjectDetector('CarDetector_0.01.xml');
detector.UseROI = true;
bbox_1 = step(detector,first_img,roi);
bbox_2 = step(detector,second_img,roi);

bbox = filter_bbox(bbox_1, bbox_2);
curr_color = zeros(size(bbox,1),3);
curr_num = zeros(size(bbox,1),1);

for i = 1: size(bbox,1)
    curr_color(i,:) = randi(255,1,3);%(rand(3,1))';
    curr_num(i) = car_count;
    car_count = car_count + 1;
end

prev_bbox.bbox = bbox;
prev_bbox.color = curr_color;
prev_bbox.num = curr_num;
%% Initialize the tracker
pointTracker = vision.PointTracker;
%% Looping over rest of the frames with Point Tracking- 
fprintf('Processing Images in the folder %s\n', inpFramesPath);
filePattern = sprintf('%s/*.jpg', inpFramesPath);
baseFileNames = dir(filePattern);
numberOfImageFiles = length(baseFileNames);
prev_img = first_img;
for i=2:300
    curr_file_name = sprintf('Frame %d.jpg', i);
    curr_full_file_name = fullfile(inpFramesPath, curr_file_name);
    next_img = imread(curr_full_file_name);
    if(floor(i / N) * N - i == 0)
        %Run the detector again and check whether we should add new bboxes
        bbox_1 = step(detector,prev_img,roi);
        bbox_2 = step(detector,next_img,roi);
        bbox = filter_bbox(bbox_1, bbox_2);
        prev_bbox = check_for_new_detection(bbox, prev_bbox);
    end
    % Reinitialize the curr_bbox
    curr_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
    temp_bbox = [];
    temp_colour = [];
    temp_num = [];
    for j = 1:size(prev_bbox.bbox,1)
        prev_box = prev_bbox.bbox(j,:);
        area_1 = prev_box(1,3) * prev_box(1,4);
        points_old = detectFASTFeatures(rgb2gray(prev_img), 'ROI', prev_box);
        initialize(pointTracker,points_old.Location,prev_img);
        [points_new,~] = step(pointTracker,next_img);
        tform = estimateGeometricTransform(points_old.Location, points_new, 'affine');
        coords = bbox2points(prev_box);
        X = transformPointsForward(tform, coords); 
        X = point2bbox(X);
        area_2 = X(1,3) * X(1,4);
        cent_old = get_centroid(prev_box);
        cent_new = get_centroid(X);
        asp_ratio = X(3) / X(4);
        if hypot((cent_new(1) - cent_old(1)),(cent_new(2) - cent_old(2))) < bbox_dist_thresh &&...
                (area_1 / area_2) > min_bbox_ratio && (area_1 / area_2) < max_bbox_ratio &&...
                asp_ratio > min_aspect_ratio_thresh && asp_ratio < max_aspect_ratio_thresh
            temp_bbox = [temp_bbox;X];
            temp_colour = [temp_colour;prev_bbox.color(j,:)];
            temp_num = [temp_num;prev_bbox.num(j)];
        end 
        pointTracker.release();
    end
    for t = 1: size(temp_bbox,1)
        curr_bbox.bbox(t,:) = temp_bbox(t,:);
        curr_bbox.color(t,:) = temp_colour(t,:);%(rand(3,1))';
        curr_bbox.num(t) = temp_num(t);
    end
 %% Rendering   
    RGB = next_img;
    for k = 1 : size(curr_bbox.bbox,1)
        thisBB = curr_bbox.bbox(k,:);
        %if thisBB(1) == 0 && thisBB(2) == 0
        %    continue;
        %end
        RGB = insertShape(RGB, 'Rectangle', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
             'Color',curr_bbox.color(k,:),'LineWidth', 2);
        text_str = strcat('Car_',num2str(curr_bbox.num(k)));
        RGB = insertText(RGB,thisBB(1:2),text_str,'FontSize',12,'BoxColor',...
            curr_bbox.color(k,:),'BoxOpacity',0.6,'TextColor','black', 'AnchorPoint','LeftBottom');
    end
    %figure(1)
    %imshow(RGB)
    outputFileName = fullfile(outputFramesPath,curr_file_name);
    imwrite(RGB,outputFileName);
    prev_img = next_img;
    prev_bbox = curr_bbox;
end