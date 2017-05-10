%%%%%%%%%%Script not used in the final Implementation%%%%%%%%%%%
%% Test the trained classifier on the given video sequence
%TODO: test for 20-30 frames
%Detection is time consuming
detector = vision.CascadeObjectDetector('CarDetector.xml');
%hblob = vision.BlobAnalysis('BoundingBoxOutputPort', true,'MinimumBlobAreaSource', 'Property','MinimumBlobArea', 200);

for i=1:1
    filename = sprintf('Frame %d.jpg', i);
    img = imread(filename);
    
    x=[217 696 698 219];
    y=[296 296 444 422];
    m= 480; n=704;
    
    %rect= [217 296 698 444];
    %Icrop= imcrop(img,rect);
    %imshow(Icrop);
    mask = poly2mask(x, y, m, n);
    imdouble= im2double(img);
    roi = imdouble.*repmat(mask,[1,1,3]);
    
    bbox = step(detector,roi);  %[x y width height]
    detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'Car 1');
    figure;
    imshow(detectedImg);
end

% cropped each bounding box to re query the classifier , but not working 
% for i= 1:length(bbox)
%     Icrop= imcrop(img,bbox(i,:));
%     %figure; imshow(Icrop);
%     bbox2= step(detector,Icrop);
%     detectedImg2 = insertObjectAnnotation(Icrop,'rectangle',bbox2,'Car'); 
%     figure; imshow(Icrop);
% end






