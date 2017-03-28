%% Read the Image and get the correct channel for blue
for i = 35412:35412
    image_name =strcat('image.0',num2str(i), '.jpg');
    filename = fullfile('bluesign', image_name);
    if exist(filename, 'file')
        im = imread(filename); %719 %686
    else
        continue;
    end
    im_d = im2double(im);
    im_c = imadjust(im_d, stretchlim(im_d));
    im_b = im_c(:,:,3);
    im_b = medfilt2(im_b, [3 3]); 
    im_b = (im_b - im_c(:,:,1)) ./ (im_c(:,:,1) + im_c(:,:,2) + im_c(:,:,3));
    im_b_usig = im2uint8(im_b);
    im_b = im_b_usig;
    %imtool(im_b)
    %% Crop only a specific region for finding the sign
    im_roi = im_b(1:500,:); 
    %% Apply MSER
    %im_b_2 = uint8(im_b);he
    %imtool(im_b_2)
    %On Original Image
    % [r,f] = vl_mser(im_roi,'MinDiversity',0.7,...
    %                 'MaxVariation',0.2,...
    %                 'Delta',8, 'DarkOnBright', 0, 'MaxArea', 0.005, 'MinArea', 0.0001 ) ;
    [r,f] = vl_mser(im_roi,'MinDiversity',0.7,...
                    'MaxVariation',0.2,...
                    'Delta',8, 'DarkOnBright', 0, 'MaxArea', 0.01, 'MinArea', 0.0001 ) ;
    f = vl_ertr(f) ;
    %vl_plotframe(f) ;
    M = zeros(size(im_b)) ;
    count = 1;
    sAll = [];
    for x=r'
     s = vl_erfill(im_roi,x) ;
     sAll = [sAll;s];
     %M(s) = M(s) + 1;
    %  MasksTemp = zeros(size(im_b));
    %  MasksTemp(s) = 1;
    %  imshow(MasksTemp);
    %  [r,c] = ind2sub(size(im_b),s);
    %  hold on;
    %  plot(c,r,'r.');
    end
    % Obtain the output in the original size image
    M_roi = zeros(500, size(im_b,2));
    M_roi(sAll) = 1;
    %imtool(M_roi)
    M(1:500,:) = M(1:500,:) + M_roi;
    %imtool(M)
    %% Plot the MSER contours
    %figure(2) ;
    %clf ; imagesc(im_b) ; hold on ; axis equal off; colormap gray ;
    %[c,h]=contour(M,(0:max(M(:)))+.5) ;
    %et(h,'color','y','linewidth',3) ;
    %% Colour Thresholding and combine the two results
    im_hsv = rgb2hsv(im);
    im_h = im_hsv(:,:,1);
    im_s = im_hsv(:,:,2);
    im_v = im_hsv(:,:,3);
    %im_h_bw = im_h >= 0.5 & im_h <= 0.6;
    im_s_bw = im_s >= 0.35 & im_s <= 0.8; % decreased lower bound from 0.6 to 0.35
    im_v_bw = im_v >= 0.35 & im_v <= 1;
    %imtool(im_s_bw)
    %imtool(M)
    im_final = M & im_s_bw & im_v_bw;
    %imtool(im_final)
    %imtool(im_hsv(:,:,1));
    %imtool(im_hsv(:,:,2));
    %imtool(im_hsv(:,:,3));
    %% Morphological Cleaning
    % Approach 1
%     struct = strel('rectangle', [2 2]);
%     im_erode = imerode(im_final, struct);
%     struct_2 = strel('rectangle', [2 2]);
%     im_dilate = imdilate(im_erode, struct_2);
%     im_dilate = imfill(im_dilate, 'holes');
%     im_filtered = medfilt2(im_dilate, [5 5]);
%     imshow(im_filtered)
    % Approach 2 - Slightly Better
    struct_2 = strel('rectangle', [3 3]);
    im_dilate = imdilate(im_final, struct_2);
    %im_dilate = imfill(im_dilate, 'holes');
    im_filtered = medfilt2(im_dilate, [5 5]); %[2 2]
    struct = strel('rectangle', [5 5]);  %[2 2]
    im_erode = imerode(im_filtered, struct);
    im_erode = imfill(im_erode, 'holes');
    %imshow(im_erode)
   %% Get the Bounding Box from the Region 
   %CC = bwconncomp(im_erode);
   label = bwlabel(im_erode);
   S = regionprops(logical(im_erode), 'Area', 'BoundingBox');
   allArea = [S.Area];
   if isempty(allArea)
       continue;
   end
   [~,ind] = sort(allArea, 'descend');
   bbox = S(ind(2)).BoundingBox;
   figure(2)
   imshow(im)
   hold on;
   rectangle('position',bbox,'Edgecolor','g', 'linewidth', 2)
   %% Save the File
   filename = sprintf('im_blue_1_ %d.jpg',i);
   output_folder = ('bluesignoutputs');
   hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
