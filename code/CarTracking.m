%% Params
N = 30; % Number of frames after which detector should be called again
global bbox_dist_thresh;
global min_bbox_ratio;
global max_bbox_ratio;
global max_area_bbox;
global min_area_bbox;
global bbox_exist;
global car_count;
bbox_dist_thresh = 10;
min_bbox_ratio = 0.7;
max_bbox_ratio = 1.3;
max_area_bbox = 100 * 100;
min_area_bbox = 30 * 30;
bbox_exist = 5;
car_count = 1;

roi_row = 300;
%% Initialize the bbox structs
field_1 = 'bbox';
field_2 = 'color';
field_3 = 'num';
value_1 = {[]};
prev_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
curr_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
%% Detection Init
inpFramesPath = '..\input\simple';
second_frame = 'Frame 2.jpg';
first_frame = 'Frame 1.jpg';
second_file = fullfile(inpFramesPath, second_frame);
first_file = fullfile(inpFramesPath, first_frame);
first_img = imread(first_file);
second_img = imread(second_file);
roi = [1,roi_row,size(first_img,2),size(first_img,1)-roi_row];

detector = vision.CascadeObjectDetector('CarDetector_0.01.xml');
detector.UseROI = true;
bbox_1 = step(detector,first_img,roi);
bbox_2 = step(detector,second_img,roi);

bbox = filter_bbox(bbox_1, bbox_2);
curr_color = zeros(size(bbox,1),3);
curr_num = zeros(size(bbox,1),1);

for i = 1: size(bbox,1)
    curr_color(i,:) = (rand(3,1))';
    curr_num(i) = car_count;
    car_count = car_count + 1;
end

prev_bbox.bbox = bbox;
prev_bbox.color = curr_color;
prev_bbox.num = curr_num;

%% Testing
detectedImg = insertObjectAnnotation(first_img,'rectangle',bbox,'Car 1');
figure;
imshow(detectedImg)
%% Initialize the tracker
pointTracker = vision.PointTracker;
%% Looping over rest of the frames - 
fprintf('Processing folder %s\n', inpFramesPath);
filePattern = sprintf('%s/*.jpg', inpFramesPath);
baseFileNames = dir(filePattern);
numberOfImageFiles = length(baseFileNames);
curr_file_names = {baseFileNames.name};
prev_img = first_img;
for i=2:2
    curr_file_name = fullfile(inpFramesPath,cell2mat(curr_file_names(i)));
    next_img = imread(curr_file_name);
    %if(floor(i / N) * N - i == 0)
    for j = 1:size(prev_bbox.bbox,1)
        prev_box = prev_bbox.bbox(j,:);
        area_1 = prev_box(1,3) * prev_box(1,4);
        %im_temp = rgb2gray(imcrop(prev_img,prev_box));
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
        if hypot((cent_new(1) - cent_old(1)),(cent_new(2) - cent_old(2))) < bbox_dist_thresh &&...
                (area_1 / area_2) > min_bbox_ratio && (area_1 / area_2) < max_bbox_ratio
            curr_bbox.bbox(j,:) = X;
            curr_bbox.color(j,:) = prev_bbox.color(j,:);
            curr_bbox.num(j) = prev_bbox.num(j);
        end 
        pointTracker.release();
    end
    figure
    imshow(next_img)
    hold on
    for k = 1 : size(curr_bbox.bbox,1)
        thisBB = curr_bbox.bbox(k,:);
        if thisBB(1) == 0 && thisBB(2) == 0
            continue;
        end
        rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
        'EdgeColor',curr_bbox.color(k,:),'LineWidth',2 )
    end
    prev_img = next_img;
    prev_bbox = curr_bbox;
end