function [R, t] = disambiguateChoices(Cset, Rset, R_t)
ind = [];
new_cset = {};
j = 1;
for i = 1: length(Cset)
    C = R_t * Cset{i};
    if (C(3,1) > 0)
        ind = [ind;i];
        new_cset{j} = C;
        j = j + 1;
    end
end

if (size(ind,1) > 0)
    min_xy = new_cset{1}(1)^2 + new_cset{1}(2)^2;
    min_ind = ind(1);
    for j = 2: size(ind,1)
        curr_min_xy = new_cset{j}(1)^2 + new_cset{j}(2)^2;
        if curr_min_xy < min_xy
            min_xy = curr_min_xy;
            min_ind = ind(j);
        end
    end
   R = Rset{min_ind};
   theta = atan2(R(3,1), R(1,1));
   curr_heading = theta * 180 / pi;
   if curr_heading > 3
       R = [cos(theta) 0 -sin(theta);0 1 0;sin(theta) 0 cos(theta)];
       t = Cset{min_ind};
   else
       R = eye(3);
       t = [0;0;Cset{min_ind}(3,1)];
   end
else
    R = eye(3);
    t = [0;0;0];
end