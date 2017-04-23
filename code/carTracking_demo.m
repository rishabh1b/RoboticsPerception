%% Test the trained classifier on the given video sequence
%TODO: test for 20-30 frames
%Detection is time consuming
detector = vision.CascadeObjectDetector('CarDetector.xml');
img = imread('Frame 1.jpg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'Car 1');
figure;
imshow(detectedImg);