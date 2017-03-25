for i=400:1260
    datafolder= sprintf('Frames');
    filename = sprintf('Frame %d.jpg', i);
    fullfilename = fullfile(datafolder,filename);
    
    I= imread(fullfilename);
    grey=rgb2gray(I);
    threshold = graythresh(grey);
    im2=medfilt2(grey,[5 5]);
        
    x=[539 680 1256 89];
    y=[419 417 708 716];
    m= 720; n=1280;
    
    mask = poly2mask(x, y, m, n);
    mask_img=im2double(grey).*mask;
    Imdouble= im2double(I);
    Inew = Imdouble.*repmat(mask,[1,1,3]);
    hsvimg= rgb2hsv(Inew);

    lane= hsvimg(:,:,3)> 0.6;
    bw1 = bwareaopen(lane,10); % adjust the pixel value based on the hough output
    %figure(1),imshow(bw1);
    
    %apply canny
    canny= edge(bw1,'canny',0.5);
    %sobel= edge(bw1,'sobel','horizontal');
    %imshow(canny);
    %figure(2),imshow(sobel);
    
 
%     blackimg = zeros(size(grey));
%     laneimg = Imdouble.*repmat(lane,[1,1,3]);
%     greylaneimg= rgb2gray(laneimg);
%     
%     BW_lane= imbinarize(greylaneimg);
%     
%     figure(2),imshow(BW_lane);
    
    
   %% old code
    
%     SegImage = imbinarize(grey,threshold);
%     %figure(1),imshow(SegImage);
%     
%     bw1 = bwareaopen(SegImage,30);
%     %figure(2),imshow(bw1)
%     
%     erodedI = bw1;
%     % segmentation
%     [L,num] = bwlabel(erodedI>0,8); %connected object, default is 8
   
%     Img2= edge(L,'canny');
%     imshow(Img2);
%     stats = regionprops(L, 'Area');
    
    %% old code
    
%     Img2= edge(im2,'canny',0.4);
%     imshow(grey);
%     hold on
%     h= impoly(gca,[536,450;759,458;1240,715;252,708]);
%     setColor(h,'yellow'); 
  
%% 
    % finding hough 
    [H,theta,rho] = hough(canny);
%     figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
%     'InitialMagnification','fit');
%     xlabel('\theta (degrees)'), ylabel('\rho');
%     axis on, axis normal, hold on;
%     colormap(hot)
    
    % Finding the Hough peaks (number of peaks is set to 10)
    P = houghpeaks(H,15,'threshold',ceil(0.2*max(H(:))));
    x = theta(P(:,2));
    y = rho(P(:,1));
%     plot(x,y,'s','color','black');

    % Fill the gaps of Edges and set the Minimum length of a line
    lines = houghlines(bw1,theta,rho,P,'FillGap',20);
    imshow(canny), hold on
    max_len = 0;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','green');
    end
    hold off
end