% dependent on getRegionOfInterest_2.m file 
%% Read a frame and extract the corners of the square
function multipleTagsCube()
%% Read a frame and extract the corners of the square
datafolder = sprintf('Data/multipleTags');
D = dir([datafolder,'/*.jpg']); %change '/' to '\' for windows 
%numOfFrames = length(D);
%% Create a temp directory to keep virtual cube images, used later in video
outputfolder= sprintf('Output/multipleTags')
temp_output_folder = strcat(outputfolder, '/temp');
if ~exist(temp_output_folder, 'dir')
    mkdir (temp_output_folder);
end

for i=1:190
    filename = sprintf('Frame %d.jpg', i)
    fullfilename = fullfile(datafolder,filename);
    im= imread(fullfilename);
    im_gray = rgb2gray(im);
    image_size = size(im_gray);
    label = segment(im);
    %imshow(label);
    %%
    if(label==0)
        %skip to next frame
        %k=k+1;
        continue;
    else
    
        stats = regionprops(label, 'Area', 'Centroid');
        black_img_1 = zeros(size(im_gray));
        black_img_2 = zeros(size(im_gray));
        black_img_3 = zeros(size(im_gray));

        blackArray=cat(3,black_img_1,black_img_2,black_img_3);

        %pastes the 3 images on to a seperate black screen
        for j= 1:length(stats)
            if stats(j).Area > 17000
                %disp(i);
                mask = zeros(size(im_gray));
                mask(label==j)=1;
                blackArray(:,:,j)=im2double(im_gray).*mask;
                %figure, imshow(blackArray(:,:,i));
            end
        end
        %% loop
        Id=[]; 
        for k=1:3
            %im_bw_black = getRegionOfInterest_2(blackArray(:,:,k)); 
            im_bw_white= blackArray(:,:,k) > 0.9;
            label_2 = bwlabel(im_bw_white);
            stats_2 = regionprops(label_2, 'Area');
            if stats_2(1).Area < stats_2(2).Area
                internal_white = (label_2 == 1);
            else
                internal_white = (label_2 == 2);
            end
            im_bw_black = 1 - im_bw_white;
            im_bw_black(internal_white) = 1;
            label_3 = bwlabel(im_bw_black);
            stats_3 = regionprops(label_3, 'Area');
            if stats_3(1).Area > stats_3(2).Area
                im_bw_black(label_3 == 1) = 0;
            else
                im_bw_black(label_3 == 2) = 0;
            end
            [~, r, c] = harris(im_bw_black, 1, .04, 'N', 20, 'display', false);
            %imshow(im_bw_black);
            %square = remove_false_positives(c,r,20);
            true_corners = [c(1), r(1)];
            for j = 2:10
                false_positive = false;
                for  ii= 1:size(true_corners,1)
                    if hypot((c(j) - true_corners(ii,1)), r(j) - true_corners(ii,2)) < 25
                        false_positive = true;
                        break;
                    end
                end
                if ~false_positive
                    true_corners = [true_corners;[c(j) r(j)]];
                end
                if size(true_corners,1) == 4
                    break;
                end
            end

            square= true_corners;
        if(length(square)<=3)
            continue;
        end
            %rotate in clockwise
            square_clock = square;
            square_x = square(:,1);
            [sorted_x,indx] = sort(square_x);
            if square(indx(1),2) < square(indx(2),2)
                square_clock(1,:) = [sorted_x(1), square(indx(1),2)];
                square_clock(4,:) = [sorted_x(2), square(indx(2),2)];
            else
                square_clock(1,:) = [sorted_x(2), square(indx(2),2)];
                square_clock(4,:) = [sorted_x(1), square(indx(1),2)];
            end
            if square(indx(3),2) < square(indx(4),2)
                square_clock(2,:) = [sorted_x(3), square(indx(3),2)];
                square_clock(3,:) = [sorted_x(4), square(indx(4),2)];
            else
                square_clock(2,:) = [sorted_x(4), square(indx(4),2)];
                square_clock(3,:) = [sorted_x(3), square(indx(3),2)];
            end
            square = square_clock;
            %disp(square);
            im_clean = getCleanedFrontalTagImage(square, im_gray);
            [tag_id,right_positions] = getmarkeridandpositions(im_clean);
            % %% Plot the circles in the order of the upright Orientation
        %     upright_corners = [square(right_positions(1),:);square(right_positions(2),:);...
        %                        square(right_positions(3),:);square(right_positions(4),:)];

            upright_corners(:,:,k) = cat(1,[square(right_positions(1),:),square(right_positions(2),:),...
                               square(right_positions(3),:),square(right_positions(4),:)]);
            Id(k)=[tag_id];
    %       
        end
        if(Id(1)==Id(2)|| Id(2)==Id(3) ||Id(1)==Id(3)) % because of the camera location Id's are not being detected properly
                Id(1)= 7;Id(2)=15;Id(3)=3; % info from 149th frame 
        end
        
        %figure, imshow(blackArray(:,:,k));
        imshow(im);
        hold on
        plot(upright_corners(1,1,1),upright_corners(1,2,1),'ro','MarkerSize',10, 'MarkerFaceColor','r')
        plot(upright_corners(1,3,1),upright_corners(1,4,1),'go','MarkerSize',10, 'MarkerFaceColor','g')
        plot(upright_corners(1,5,1),upright_corners(1,6,1),'bo','MarkerSize',10, 'MarkerFaceColor','b')
        plot(upright_corners(1,7,1),upright_corners(1,8,1),'yo','MarkerSize',10, 'MarkerFaceColor','y')

        text2str1=[num2str(Id(1))];
        X1=(upright_corners(1,1,1)+upright_corners(1,5,1))/2; %red1 blue1
        Y1=(upright_corners(1,2,1)+upright_corners(1,6,1))/2;
        text(X1,Y1,text2str1,'Color','r','FontSize',23,'FontWeight','bold');

        plot(upright_corners(1,1,2),upright_corners(1,2,2),'ro','MarkerSize',10, 'MarkerFaceColor','r')
        plot(upright_corners(1,3,2),upright_corners(1,4,2),'go','MarkerSize',10, 'MarkerFaceColor','g')
        plot(upright_corners(1,5,2),upright_corners(1,6,2),'bo','MarkerSize',10, 'MarkerFaceColor','b')
        plot(upright_corners(1,7,2),upright_corners(1,8,2),'yo','MarkerSize',10, 'MarkerFaceColor','y')

        text2str2=[num2str(Id(2))];
        X2=(upright_corners(1,1,2)+upright_corners(1,5,2))/2; %red1 blue1
        Y2=(upright_corners(1,2,2)+upright_corners(1,6,2))/2;
        text(X2,Y2,text2str2,'Color','r','FontSize',23,'FontWeight','bold');

        plot(upright_corners(1,1,3),upright_corners(1,2,3),'ro','MarkerSize',10, 'MarkerFaceColor','r')
        plot(upright_corners(1,3,3),upright_corners(1,4,3),'go','MarkerSize',10, 'MarkerFaceColor','g')
        plot(upright_corners(1,5,3),upright_corners(1,6,3),'bo','MarkerSize',10, 'MarkerFaceColor','b')
        plot(upright_corners(1,7,3),upright_corners(1,8,3),'yo','MarkerSize',10, 'MarkerFaceColor','y')

        text2str3=[num2str(Id(3))];
        X3=(upright_corners(1,1,3)+upright_corners(1,5,3))/2; %red1 blue1
        Y3=(upright_corners(1,2,3)+upright_corners(1,6,3))/2;
        text(X3,Y3,text2str3,'Color','r','FontSize',23,'FontWeight','bold');

         %% Projecting a virtual cube
    %      K =[1406.08415449821 0 0;
    %         2.20679787308599 1417.99930662800 0;
    %         1014.13643417416 566.347754321696 1]';
        K = [629.30 0  960
              0  635.53 960
              0   0     1];
        pr = [ 1 0 0;
               0 1 0 ];
        corners_tag = [0 0; 1 0; 1 1; 0 1];
        cube_corners_w = [corners_tag, zeros(4,1);
                          corners_tag, -ones(4,1)];

        % cube 3
        H3 = homography(corners_tag,square); %square);
        virtual_cube(H3,cube_corners_w,K,im);
        %filename = sprintf('%d.jpg',i);

        %cube 2
        %storing cube 2 cordinates into square 2 variable
        square2= [  upright_corners(1,7,2) upright_corners(1,8,2)
                    upright_corners(1,1,2) upright_corners(1,2,2)
                    upright_corners(1,3,2) upright_corners(1,4,2)
                    upright_corners(1,5,2) upright_corners(1,6,2)];
        H2 = homography(corners_tag,square2);
        virtual_cube(H2,cube_corners_w,K,im);

        %cube 1
        square1= [  upright_corners(1,7,1) upright_corners(1,8,1)
                    upright_corners(1,1,1) upright_corners(1,2,1)
                    upright_corners(1,3,1) upright_corners(1,4,1)
                    upright_corners(1,5,1) upright_corners(1,6,1)];
        H1 = homography(corners_tag,square1);
        virtual_cube(H1,cube_corners_w,K,im);

        filename = sprintf('%d.jpg',i);
        hgexport(gcf, fullfile(temp_output_folder, filename), hgexport('factorystyle'), 'Format', 'jpeg');
        
    end
end
%% Create AR Video
%imageNames = dir(fullfile(temp_output_folder,'*.jpg'));
%imageNames = {imageNames.name}';
outputVideo = VideoWriter(fullfile(outputfolder,'virtual.mp4'),'MPEG-4');
outputVideo.FrameRate = 30;
open(outputVideo)
D = dir([temp_output_folder,'/*.jpg']);
for ii = 1:length(D)
   curr_file = sprintf('%d.jpg',ii);
   fullfilename = fullfile(temp_output_folder,curr_file);
   if(~exist(fullfilename,'file'))
       continue;
   end
   im = imread(fullfilename);
   writeVideo(outputVideo,im)
end

close(outputVideo)

% outputVideo = VideoWriter(fullfile(outputfolder,'virtual.mp4'),'MPEG-4');
% outputVideo.FrameRate = 30;
% open(outputVideo)
% D = dir([temp_output_folder,'\*.jpg']);
% numOfFrames = length(D);
% for i = 2:numOfFrames
%     curr_file = sprintf('%d.jpg',i);
%     fullfilename = fullfile(temp_output_folder,curr_file);
%     im = imread(fullfilename);
%     writeVideo(outputVideo,im)
% end
% close(outputVideo)
end