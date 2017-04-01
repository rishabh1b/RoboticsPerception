%% Read images
for i=33704:33704 %image.034404
    image_name =strcat('image.0',num2str(i), '.jpg');
    filename = fullfile('input', image_name);
    if exist(filename, 'file')
        I = imread(filename); %32719 %686 %35412
   
    else
        continue;
    end
    imshow(I);
%     datafolder= sprintf('input');
%     filename = sprintf('image.03440%d.jpg', i);
%     fullfilename = fullfile(datafolder,filename);

%    I= imread(fullfilename);
    im_hsv= rgb2hsv(I);
    im_hue = im_hsv(:,:,1);
    im_sat = im_hsv(:,:,2);
    im_val = im_hsv(:,:,3);
    %imtool(im_hsv);
    
%% HSV threshold
% depends on the shape and color of the signs 
   %Binarize each plane and show the blue color image.032742 and .033760
    h_bin = im_hue >= 0.45 & im_hue < 0.62;
    s_bin = im_sat >= 0.60 & im_sat <=0.84;
    v_bin = im_val >= 0.30 & im_val <=0.54 ;
    blue_mask = h_bin & s_bin & v_bin;
    %imshow(blue_mask);
    
    %Binarize each plane and show the red color image.034404
    h_bin1 = im_hue >= 0.00 & im_hue < 0.02;
    s_bin1 = im_sat >= 0.60 & im_sat <=0.77;
    v_bin1 = im_val >= 0.20 & im_val <=0.65 ;
    red_mask = h_bin1 & s_bin1 & v_bin1;
    imshow(red_mask);
%% Fill the image holes

%% Define shapes   
    blue_stats = regionprops(blue_mask,'Area','Perimeter','Eccentricity','BoundingBox');
    red_stats = regionprops(red_mask,'Area','Perimeter','Eccentricity','BoundingBox');
    
    
    
    %CircleMetric_blue = (blue_stats.Perimeter.^2)./(4*pi*blue_stats.Area);  %circularity metric
 %%  Identify road signs
   imshow(I);
   hold on
    %blue
    for id=1:length(blue_stats)
        if(blue_stats(id).Area >150) %count only large signs i.e excludes noise
            if(blue_stats(id).Eccentricity>=0.9 &&blue_stats(id).Eccentricity<=1) %circular blue signs adjust eccentricity value %image.033653.jpg
                bb = blue_stats(id).BoundingBox;
                rectangle('Position',[bb(1) bb(2) bb(3) bb(4)],'LineWidth',4,'EdgeColor','green');
            end
            % square image.034770
            
            % triangle
        end
    end
    
    %red
    for idx=1:length(red_stats)
        if(red_stats(idx).Area >70) %count only large signs i.e excludes noise
            if(red_stats(idx).Eccentricity>=0.35 && red_stats(idx).Eccentricity<=1) %circular blue signs
                bb1 = red_stats(idx).BoundingBox;
                rectangle('Position',[bb1(1) bb1(2) bb1(3) bb1(4)],'LineWidth',4,'EdgeColor','green');
            end
        end
    end
%% Save the images into the temp folder
    filename = sprintf(image_name);
    debug_output_folder = sprintf('temp2');
    hgexport(gcf, fullfile(debug_output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
    
end