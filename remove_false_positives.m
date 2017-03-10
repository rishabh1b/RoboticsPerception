function true_corners = remove_false_positives(c, r, num_of_points)
%thresh_dist = 40
true_corners = [c(1), r(1)];
for j = 2:num_of_points
    false_positive = false;
    for k = 1:size(true_corners,1)
        if hypot((c(j) - true_corners(k,1)), r(j) - true_corners(k,2)) < 30
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
end