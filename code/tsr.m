% Function to Segment and Identify traffic signs
%% Define some threshold parameters
min_blob_area = 600; % for considering any region worthy enough to predict a traffic sign
max_error_score = 0.06; % for acceptable error margin in prediction
                        % If > than this value, we have a false positive
blobs_to_consider = 4; % Consider this much blobs at any given frame
                       % prediction will be done for all these blobs
cell_size = 8;         %For Hog
req_aspect_ratio = 0.3; % Aspect ratio of the bounding boxes should be greater than
                        % this value
%% Where to show the sign?
size_train_image = 120;

% Placing the traffic sign at the bottom
%sign_pos_arr = [(1236-size_train_image+1) 1236 1 size_train_image; (1236-size_train_image+1) 1236 (1628-size_train_image+1) 1628];

%Placing it at the top
sign_pos_arr = [1 size_train_image (1628-size_train_image+1) 1628;1 size_train_image 1 size_train_image];
%% Read the Image and get the correct channel for blue
for i = 32686:32856
    image_name =strcat('image.0',num2str(i), '.jpg');
    filename = fullfile('signs', image_name);
    if exist(filename, 'file')
        im = imread(filename); %719 %686%35412 %33651 %33755:33764
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
    %On Original Image
    % [r,f] = vl_mser(im_roi,'MinDiversity',0.7,...
    %                 'MaxVariation',0.2,...
    %                 'Delta',8, 'DarkOnBright', 0, 'MaxArea', 0.005, 'MinArea', 0.0001 ) ;
    
    % On a extracted region of interest - increases speed somewhat
    [r,f] = vl_mser(im_roi,'MinDiversity',0.7,...
                    'MaxVariation',0.2,...
                    'Delta',8, 'DarkOnBright', 0, 'MaxArea', 0.01, 'MinArea', 0.0001 ) ;
    f = vl_ertr(f) ;
    M = zeros(size(im_b)) ;
    count = 1;
    sAll = [];
    for x=r'
     s = vl_erfill(im_roi,x) ;
     sAll = [sAll;s];
    end
    % Obtain the output in the original size image
    M_roi = zeros(500, size(im_b,2));
    M_roi(sAll) = 1;
    M(1:500,:) = M(1:500,:) + M_roi;
    %imtool(M)
    %% Plot the MSER contours
    %figure(2) ;
    %clf ; imagesc(im_b) ; hold on ; axis equal off; colormap gray ;
    %[c,h]=contour(M,(0:max(M(:)))+.5) ;
    %et(h,'color','y','linewidth',3) ;
    %% Colour Thresholding and combine the these with MSER
    im_hsv = rgb2hsv(im);
    im_h = im_hsv(:,:,1);
    im_s = im_hsv(:,:,2);
    im_v = im_hsv(:,:,3);
    im_s_bw = im_s >= 0.45 & im_s <= 0.8; % decreased lower bound from 0.6 to 0.35 to 0.45
    im_v_bw = im_v >= 0.35 & im_v <= 1; % Could be done away with
    im_final = M & im_s_bw & im_v_bw;
    %imtool(im_final)
    %imtool(im_hsv(:,:,1));
    %imtool(im_hsv(:,:,2));
    %imtool(im_hsv(:,:,3));
    %% Morphological Cleaning
    % Approach 2 - Slightly Better, see debug branch for more
    struct_2 = strel('rectangle', [3 3]);
    im_dilate = imdilate(im_final, struct_2);
    im_filtered = medfilt2(im_dilate, [5 5]); %[2 2]
    struct = strel('rectangle', [5 5]);  %[2 2]
    im_erode = imerode(im_filtered, struct);
    im_erode = imfill(im_erode, 'holes');
    %imshow(im_erode)
   %% Get the Bounding Box from the Region 
   % TODO: Some hacks in a way that could track the bounding box window in 
   % high brightness area - right now it is not tracking it efficiently
   %On a second thought, it need not be very robust
   label = bwlabel(im_erode);
   S = regionprops(logical(im_erode), 'Area', 'BoundingBox');
   allArea = [S.Area];
   if isempty(allArea)
       continue;
   end
   [~,ind] = sort(allArea, 'descend'); 
   iter = min(size(allArea,2), blobs_to_consider);
   bbox = [];
   for j = 1:iter
       if allArea(ind(j)) < min_blob_area
           break;
       end
    curr_bbox = S(ind(j)).BoundingBox;
    % Get Rid of spurious blue noise and patches
    if curr_bbox(4) / curr_bbox(3) < req_aspect_ratio
        continue;
    else
        bbox = [bbox;curr_bbox];
    end
    %bbox = [bbox;curr_bbox];
   end
   im_gray = rgb2gray(im);
   %% Extract the patch corresponding to each Bounding Box
   iter = size(bbox,1);
   chosen_bbox = 0;
   chosen_bbox_arr = [];
   for j = 1:iter
       if chosen_bbox == 2
           break;   % Focus on only two traffic signs max in a single frame
       end
       curr_bbox = bbox(j,:);
       im_roi = imcrop(im_gray, curr_bbox);
       im_roi = imresize(im_roi, [64,64]);
       %% Find the sign
       hog = vl_hog(im2single(im_roi), cell_size,'variant', 'dalaltriggs') ;
       testFeatures = hog(:)';
       [predictedLabel, scores] = predict(classifier, testFeatures);
       if min(abs(scores)) > max_error_score
           continue;
       end
       % HACK for Blue - No red signs be detected in blue sign area
       [~, min_error_ind] = min(abs(scores));
       if min_error_ind <= 5
           continue;
       end
       %% Paste the image at appropriate locations in the image
       chosen_bbox_arr = [chosen_bbox_arr;curr_bbox];
       label_name = cellstr(predictedLabel);
       label_folder = cell2mat(fullfile('..\testing\subset_testing', label_name));
       D = dir([label_folder,'\*.ppm']);
       fullfilename = fullfile(label_folder,D(1).name);
       im_train = imread(fullfilename);
       im_train = imresize(im_train,[size_train_image size_train_image]);
       rect = sign_pos_arr((chosen_bbox + 1),:);
       for colorplane = 1 :3
        im(rect(1):rect(2), rect(3):rect(4), colorplane) = 0.1 * im(rect(1):rect(2), rect(3):rect(4), colorplane) + ...
            0.9 * im_train(:,:,colorplane);
       end
       chosen_bbox = chosen_bbox + 1;
   end
   %% Show the output
   figure(2)
   imshow(im)
   hold on;
   for j = 1:size(chosen_bbox_arr,1)
    rectangle('position',chosen_bbox_arr(j,:),'Edgecolor',[uint8(randi(255)), uint8(randi(255)), uint8(randi(255))], 'linewidth', 2)
   end
   %% Save the File
   filename = sprintf('im_blue_1_ %d.jpg',i);
   output_folder = ('bluesignoutputs');
   hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
