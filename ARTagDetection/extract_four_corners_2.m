function square_clock = extract_four_corners_2(r,c)
% This function was not used in the final implementation
%% Initialize different values
dist_tol = 12; %pixels
num_of_points = size(r);
square = [];
square_lengths = [];
existing_indices = [];
already_exists = false;
%% A modest algorithm to separate the points of interest(outer points of marker)
for i = 1:num_of_points
    for j = 1:num_of_points
        curr_point_1 = [c(i), r(i)];
        curr_point_2 = [c(j), r(j)];
        if j == i
            continue;
        end
        for k = 1:num_of_points
            curr_point_3 = [c(k), r(k)];
            if k == j || k == i
                continue;
            end
            for l = 1:num_of_points
                if l == k || l == j || l == i
                    continue;
                end
                curr_point_4 = [c(l), r(l)];
                AB = hypot((curr_point_2(2) - curr_point_1(2)),(curr_point_2(1) - curr_point_1(1)));
                BC = hypot((curr_point_3(2) - curr_point_2(2)),(curr_point_3(1) - curr_point_2(1)));
                CD = hypot((curr_point_4(2) - curr_point_3(2)),(curr_point_4(1) - curr_point_3(1)));
                AD = hypot((curr_point_4(2) - curr_point_1(2)),(curr_point_4(1) - curr_point_1(1)));
                BD = hypot((curr_point_4(2) - curr_point_2(2)),(curr_point_4(1) - curr_point_2(1)));
                AC = hypot((curr_point_3(2) - curr_point_1(2)),(curr_point_3(1) - curr_point_1(1)));
                if abs(AB - CD) < dist_tol && abs(BC - AD) < dist_tol && ...
                       BD > BC && AC > AD && BD > CD && BD > AD && BD > AB && AC > CD &&...
                       AC > BC && AC > AB
                       for t = 1:size(existing_indices,1)
                           index = existing_indices(t,:);
                           if any(index == i) && any(index == j) && any(index == k) && any(index == l)
                              already_exists = true;
                              break;
                           end
                       end
                       if ~already_exists
                           square = [square; curr_point_1' curr_point_2' curr_point_3' curr_point_4'];
                           square_lengths = [square_lengths;[i,j,k,l,AB+BC+CD+AD]];
                           existing_indices = [existing_indices;[i,j,k,l]];
                       end
                end
                already_exists = false;
                %dists = [dists; AB BC CD AD]
            end
        end
    end
end
%% Extract the square with largest perimeter
%sq_length = zeros(size(square_lengths,1),1);
sq_perim = square_lengths(:,5);
[~,pos] = max(sq_perim);
req_index = square_lengths(pos,1:4);
square = [c(req_index(1)) c(req_index(2)) c(req_index(3)) c(req_index(4));...
          r(req_index(1)) r(req_index(2)) r(req_index(3)) r(req_index(4))];
square = square';
%% Arrange the points in a clockwise manner
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
end