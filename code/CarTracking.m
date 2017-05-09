%% Params
N = 30; % Number of frames after which detector should be called again
global bbox_dist_thresh;
global min_bbox_ratio;
global max_bbox_ratio;
global max_area_bbox;
global min_area_bbox;
global bbox_exist;
global car_count;
bbox_dist_thresh = 5;
min_bbox_ratio = 0.7;
max_bbox_ratio = 1.3;
max_area_bbox = 100 * 100;
min_area_bbox = 30 * 30;
bbox_exist = 5;
car_count = 1;

roi_row = 260;
%% Initialize the bbox structs
field_1 = 'bbox';
field_2 = 'color';
field_3 = 'num';
value_1 = {[]};
prev_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
curr_bbox = struct(field_1, value_1, field_2, value_1, field_3, value_1);
%% Detection Init
inpFramesPath = '..\input\simple';
second_frame = 'Frame 284.jpg';
first_frame = 'Frame 283.jpg';
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
%%