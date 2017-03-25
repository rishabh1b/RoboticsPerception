% This will test the robustness of the mask across each frame.
% Current approach will focus on the use of Hough Lines directly on the 
% image provided. That is let's skip homography for now
%% Get a Test Image and denoise
im = imread('..\..\Data\normal\Frame 12.jpg');
im_gray = rgb2gray(im);
im_denoise_gray = medfilt2(im_gray, [5 5]);
imtool(im_denoise_gray)
im_hsv = rgb2hsv(im);
im_sat = im_hsv(:,:,2);
im_denoise = medfilt2(im_sat, [5 5]);
%imtool(im_denoise)
%imshow(im_gray)
%% Edge Detection
% Edge Results not exciting in the saturation plane
%BW = edge(im_denoise, 'Sobel');
%imshow(BW);
BW_2 = edge(im_denoise_gray, 'Sobel');
figure
%imshow(BW_2)
BW_3 = edge(im_denoise_gray, 'Canny');
figure
%imshow(BW_3)
%% Edge Detection with only X-Gradient Sobel Operator
edge_filter_x = [1 0 -1; 2 0 -2; 1 0 -1];
edge_filter_y = [1 2 1;0 0 0;-1 -2 -1];
output = conv2(im_denoise_gray, edge_filter_x);
imtool(output > 180)
output_2 = output > 150;
%% Hough
[H,T,R] = hough(output_2);
%P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
P  = houghpeaks(H,20);
lines = houghlines(output_2,T,R,P,'FillGap',50);
figure
imshow(im)
hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
%% Crop the Region of interest