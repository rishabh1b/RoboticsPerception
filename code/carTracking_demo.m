%% Test the trained classifier on the given video sequence
%TODO: test for 20-30 frames
%Detection is time consuming
detector = vision.CascadeObjectDetector('CarDetector_0.01.xml');
img = imread('Frame 2.jpg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'Car 1');
figure;
imshow(detectedImg);
imwrite(detectedImg, 'detectedImg.jpg')