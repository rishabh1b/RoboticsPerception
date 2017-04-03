% Function to Segment and Identify Red traffic signs
%% Define some threshold parameters
min_blob_area = 600; % for considering any region worthy enough to predict a traffic sign
max_error_score = 0.06; % for acceptable error margin in prediction
                        % If > than this value, we have a false positive
blobs_to_consider = 6; % Consider this much blobs at any given frame
                       % prediction will be done for all these blobs
cell_size = 8;         %For Hog
req_aspect_ratio = 0.7; % Aspect ratio of the bounding boxes should be greater than
                        % this value
%% Define Parameters for MSER
delta = 8;
maxarea = 0.01;
minarea = 0.0001;
%% Where to show the sign and how big should it be?
size_train_image = 170;

% Placing the traffic sign at the bottom
%sign_pos_arr = [(1236-size_train_image+1) 1236 1 size_train_image; (1236-size_train_image+1) 1236 (1628-size_train_image+1) 1628];

% Placing the traffic sign at the somewhere at the centre
cent = 1236 / 2;
sign_pos_arr = [(cent-size_train_image+1) cent 1 size_train_image; (cent-size_train_image+1) cent (1628-size_train_image+1) 1628];
%Placing it at the top
%sign_pos_arr = [1 size_train_image (1628-size_train_image+1) 1628;1 size_train_image 1 size_train_image];
%% Read the Image and get the correct channel for blue
for i = 34826:34826
    image_name =strcat('image.0',num2str(i), '.jpg');
    filename = fullfile('signs', image_name);
    if exist(filename, 'file')
        im = imread(filename); %719 %686%35412 %33651 %33755:33764 %%33416 %34753:34890
    else
        continue;
    end   
    %%%%% Red Signs
    im_r = preprocess_red(im);
    %imtool(im_r)
    %% Crop only a specific region for finding the sign
    im_roi = im_r(1:500,:); 
    %% Apply MSER
    M = find_mser(im_roi, delta, maxarea, minarea, size(im_r));
    figure(1)
    subplot(2,2,1)
    imshow(M), title('Output using only MSER')
    %% Colour Thresholding and combine it with MSER
    red_mask = threshold_red(im);
    subplot(2,2,2)
    imshow(red_mask), title('Output using only tresholding')
    im_final = M & red_mask;
    subplot(2,2,3)
    imshow(im_final), title('bitwise and on MSER and thresholding')
    %% Morphological Cleaning
    im_erode = clean_image(im_final);
    subplot(2,2,4)
    imshow(im_erode), title('Output after suitable Morphological Cleaning')
    %im_erode = clean_image(M);
%     figure(3)
%     imshow(im_erode)
   %% Get the Bounding Box from the Region 
   % TODO: Some way that could track the bounding box window in 
   % high brightness area - right now it is not tracking it efficiently
   %On a second thought, it need not be very robust
   bbox = get_bboxs(im_erode, blobs_to_consider, min_blob_area, req_aspect_ratio);
   if isempty(bbox)
       continue;
   end
   %% Extract the patch corresponding to each Bounding Box
   [chosen_bbox_arr, im, pos_train_ind_arr] = paste_valid_sign_red(bbox, im, classifier, sign_pos_arr, cell_size, max_error_score, size_train_image);
   %%%% Red Signs End here
   %% Show the output
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
   filename = sprintf('im_%d.jpg',i);
   output_folder = ('signoutputs');
   hgexport(gcf, fullfile(output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
end
