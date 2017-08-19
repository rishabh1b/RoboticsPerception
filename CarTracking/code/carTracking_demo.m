%% For testing the trained classifier on some of the frames
%Region Of interest
roi_row = 250; 
roi_col = 50;
%%
inpFramesPath = '..\input\simple';
curr_file_name = sprintf('Frame %d.jpg', 40);
curr_full_file_name = fullfile(inpFramesPath, curr_file_name);
detector = vision.CascadeObjectDetector('CarDetector_0.01.xml');
img = imread(curr_full_file_name);
bbox = step(detector,img);
bbox = test_false_positive(bbox);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'Car 1');
figure;
imshow(detectedImg);

x = roi_col;
y = roi_row;
width = size(img,2) - 2*roi_col;
height = size(img,1)-roi_row;
roi = [x,y,width,height];

% Show the Region Of Interest
rectangle('Position', roi,...
         'EdgeColor','black','LineWidth',2 )
%imwrite(detectedImg, 'detectedImg.jpg')