function im_bw_black = getRegionOfInterest(im)
im_gray = rgb2gray(im);
im_c = imadjust(im_gray, stretchlim(im_gray));
im_dbl = im2double(im_c);
im_bw_white = im_dbl > 0.9;
%% Do some neat image processing to isolate only the page components
label_w = bwlabel(im_bw_white);
stats_w = regionprops(logical(im_bw_white), 'Area', 'Centroid');
blobs_roi = zeros(2,1);
for k = 1:length(stats_w)
    if stats_w(k).Area < 100   %Spurious blobs
        im_bw_white(label_w == k) = 0;
    end
end
label_w = bwlabel(im_bw_white);
stats_w = regionprops(logical(im_bw_white), 'Area', 'Centroid');
pairfound = false;
for k = 1:length(stats_w)
    curr_cent = stats_w(k).Centroid;
    if pairfound == true
        break;
    end
    for l = k+1:length(stats_w)
        nxt_cent = stats_w(l).Centroid;
        if hypot(nxt_cent(2) - curr_cent(2), nxt_cent(1) - curr_cent(1)) < 100
            blobs_roi(1) = k;
            blobs_roi(2) = l;
            pairfound = true;
            break;
        end
    end
end

for k = 1:length(stats_w)
    if k == blobs_roi(1) || k == blobs_roi(2)
        continue;
    else
       im_bw_white(label_w == k) = 0;
    end
end       
im_bw_black = (1 - im_bw_white);
%% Process the black binary image to remove internal whites
%internal whites are due to differences in the Tag Id.
label_1 = bwlabel(im_bw_black);
stats_1 = regionprops(logical(im_bw_black), 'Area');
n = length(stats_1);
areas = zeros(n,1);
for k = 1:n
    areas(k) = stats_1(k).Area;
end
[~, ind] = sort(areas, 'descend');
%The following loop will ensure that all the regions are black,
%except the outer region of page and the outer region of the tag itself 
for l = 3:n
    im_bw_black(label_1 == ind(l)) = 0;
end
%% Get the pixel positions of internal whites in the complement of above
%Get the complement of the above processed image. Isolate internal white
%pixels. We know that that is the smaller area
im_bw_white_2 = 1 - im_bw_black;
label_2 = bwlabel(im_bw_white_2);
stats_2 = regionprops(logical(im_bw_white_2), 'Area');
%Sometime tiny white pixels start making a blob of their own, 
%Opening operation reduces the size of the region of interest,
%resulting in corners not identified accurately, to get around this problem
%choose the second from top bigger area - we know those are the internal
%pixels
n = length(stats_2);
areas = zeros(n,1);
for k = 1:n
    areas(k) = stats_2(k).Area;
end
[~, ind_2] = sort(areas, 'descend');
internal_white = (label_2 == ind_2(2));
%% Replace Outer Pixels of im_bw_black image with black and internal with white
%Make the outer region of im_bw_black as black
im_bw_black(label_1 == ind(1)) = 0;
%Make the interior region of im_bw_black as white
im_bw_black(internal_white) = 1;
%imtool(im_bw_black)
end