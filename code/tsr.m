% Function to Segment and Identify Red traffic signs
%% Define some threshold parameters
min_blob_area = 600; % for considering any region worthy enough to predict a traffic sign
max_error_score = 0.06; % for acceptable error margin in prediction
                        % If > than this value, we have a false positive
blobs_to_consider = 6; % Consider this much blobs at any given frame
                       % prediction will be done for all these blobs
cell_size = 8;         %For Hog
req_aspect_ratio = 0.4; % Aspect ratio of the bounding boxes should be greater than
                        % this value
%% Define Parameters for MSER
delta = 8;
maxarea = 0.01;
minarea = 0.0001;
%% Where to show the sign and how big should it be?
size_train_image = 120;

% Placing the traffic sign at the bottom
sign_pos_arr = [(1236-size_train_image+1) 1236 1 size_train_image; (1236-size_train_image+1) 1236 (1628-size_train_image+1) 1628];

%Placing it at the top
%sign_pos_arr = [1 size_train_image (1628-size_train_image+1) 1628;1 size_train_image 1 size_train_image];
%% Read the Image and get the correct channel for blue
for i = 35412:35412
    image_name =strcat('image.0',num2str(i), '.jpg');
    filename = fullfile('signs', image_name);
    if exist(filename, 'file')
        im = imread(filename); %719 %686%35412 %33651 %33755:33764 %%33416 %34753:34890
    else
        continue;
    end   
    im_orig = im;
    %%%%% Red Signs
    im_r = preprocess_red(im);
    %imtool(im_r)
    %% Crop only a specific region for finding the sign
    im_roi = im_r(1:500,:); 
    %% Apply MSER
    M = find_mser(im_roi, delta, maxarea, minarea, size(im_r));
    %imtool(M)
    %% Colour Thresholding and combine it with MSER
    red_mask = threshold_red(im);
    %imtool(red_mask)
    im_final = M & red_mask;
    %imtool(im_final)
    %% Morphological Cleaning
    im_erode = clean_image(M);
    %im_erode = clean_image(M);
%     figure(3)
%     imshow(im_erode)
   %% Get the Bounding Box from the Region 
   % TODO: Some way that could track the bounding box window in 
   % high brightness area - right now it is not tracking it efficiently
   %On a second thought, it need not be very robust
   bbox_r = get_bboxs(im_erode, blobs_to_consider, min_blob_area, req_aspect_ratio);
%    if isempty(bbox_r)
%        continue;
%    end
   %% Extract the patch corresponding to each Bounding Box
   [chosen_bbox_arr_r, im, pos_train_ind_arr_r, right_pos_taken] = paste_valid_sign_red(bbox_r, im, classifier, sign_pos_arr, cell_size, max_error_score, size_train_image);
   %%%% Red Signs End here
   %% Blue Signs
   %%%%% Blue Signs
    im_b = preprocess_blue(im_orig);
    %imtool(im_r)
    %% Crop only a specific region for finding the sign
    im_roi = im_b(1:500,:); 
    %% Apply MSER
    M = find_mser(im_roi, delta, maxarea, minarea, size(im_b));
    %imtool(M)
    %% Colour Thresholding and combine it with MSER
    blue_mask = threshold_blue(im_orig);
    %imtool(red_mask)
    im_final = M & blue_mask;
    %imtool(im_final)
    %% Morphological Cleaning
    im_erode = clean_image(im_final);
%     figure(3)
%     imshow(im_erode)
   %% Get the Bounding Box from the Region 
   % TODO: Some way that could track the bounding box window in 
   % high brightness area - right now it is not tracking it efficiently
   %On a second thought, it need not be very robust
   bbox_b = get_bboxs(im_erode, blobs_to_consider, min_blob_area, req_aspect_ratio);
   if isempty(bbox_b)
       continue;
   end
   %% Extract the patch corresponding to each Bounding Box
   [chosen_bbox_arr_b, im, pos_train_ind_arr_b] = paste_valid_sign_blue(bbox_b, im, classifier, sign_pos_arr, cell_size, max_error_score, size_train_image, right_pos_taken);
   %%%% Blue Signs End here
   if isempty(chosen_bbox_arr_b) && isempty(chosen_bbox_arr_r)
       continue;
   end
   %% Show the output
   chosen_bbox_arr = [chosen_bbox_arr_r; chosen_bbox_arr_b];
   pos_train_ind_arr = [pos_train_ind_arr_r; pos_train_ind_arr_b];
   figure(2)
   imshow(im)
   hold on;
   for j = 1:size(chosen_bbox_arr,1)
    rectangle('position',chosen_bbox_arr(j,:),'Edgecolor',[uint8(randi(255)), uint8(randi(255)), uint8(randi(255))], 'linewidth', 4)
    x1 = (chosen_bbox_arr(j,1) + (chosen_bbox_arr(j,1) + chosen_bbox_arr(j,3))) / 2;
    y1 = (chosen_bbox_arr(j,2) + (chosen_bbox_arr(j,2) + chosen_bbox_arr(j,4))) / 2;
    if (pos_train_ind_arr(j) == 1)
        x2 = sign_pos_arr(pos_train_ind_arr(j),4);
        y2 = sign_pos_arr(pos_train_ind_arr(j),1);
    else
        x2 = sign_pos_arr(pos_train_ind_arr(j),3);
        y2 = sign_pos_arr(pos_train_ind_arr(j),1);
    end
    plot([x1 x2], [y1 y2], 'Color', 'green', 'linewidth' , 2, 'linestyle' ,'--')
   end
   %% Save the File
   filename = sprintf('im_1_ %d.jpg',i);
   output_folder = ('signoutputs');
   hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
