function [centre, radius] = getCentreAndRadius(pixels_needed, take_lower_pixel)
% getCentreAndRadius systematically chooses three points from the given set
% of boundary pixels and obtains the radius and centre of the circles that
% fits these pixels
% Input - pixels_needed -> N x 2 array of row and column position of each
%                          boundary pixel in the image
% Output - centre -> u,v location of centre in pixel co-ordinates
%          radius -> radius of the circle
if nargin < 2
    take_lower_pixel = false;
end
[sorted_pixels,ind] = sort(pixels_needed);
pt1 = [sorted_pixels(1,2), pixels_needed(ind(1,2),1)];

if take_lower_pixel
    pt2 = [pixels_needed(ind(end,1), 2), sorted_pixels(end,1)];
else
    pt2 = [pixels_needed(ind(1,1), 2), sorted_pixels(1,1)];
end

pt3 = [sorted_pixels(end,2), pixels_needed(ind(end,2), 1)];
[centre, radius] = calcCircle(pt1, pt2, pt3);
end