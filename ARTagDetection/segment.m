function [Label] = segment(im)

image= im;
Iblur = rgb2gray(imgaussfilt(image, 4));
Img2= edge(Iblur,'canny',0.3);
%imshow(Img2);
Img3=im2double(Img2);
bw = imbinarize(Img3,0.8);
bw = bwareaopen(bw,20); 
se = strel('disk',2);

bw = imclose(bw,se);
    
bw = imfill(bw,'holes');
%figure
%imshow(bw)
[Label,~]=bwlabel(bw,8);

end

