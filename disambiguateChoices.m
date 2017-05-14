function [R, t] = disambiguateChoices(Cset, Rset)
% Cset has values of the next camera pose with reference to the last camera
% pose, in other words it is the relative translation
ind = [];

% Filter One - Local Z should always be positive - with the assumption that
% car is always moving forward
for i = 1: length(Cset)
    selected_trans_debug = Cset{i};
    if (Cset{i}(3,1) > 0)
        ind = [ind;i];
        %new_cset{j} = C;
        %j = j + 1;
    end
end

% Filter two- Check for rotational matrix elements- 
new_Rset = {};
j = 1;
ind_2 = [];
if (size(ind,1) > 0)
    for i=1:size(ind,1)
        R_test = Rset{ind(i)};
       if R_test(2,2) > 0.9 && abs(R_test(1,2)) < 0.1 && abs(R_test(2,1)) < 0.1 && ...
          abs(R_test(2,3)) < 0.1 && abs(R_test(3,2)) < 0.1
          new_Rset{j} = R_test;
          j = j + 1;
          ind_2 = [ind_2;ind(i)];
       end
    end
    % Filter three - pick the matrix with minimum y translation
    if (size(ind_2,1) > 0)
        R = new_Rset{1};
        selected_trans_debug = Cset{ind_2(1)};
        t = [Cset{ind_2(1)}(1);0;Cset{ind_2(1)}(3)];
        min_y = abs(Cset{ind_2(1)}(2));
        for i = 2: size(ind_2,1)
            curr_min_y = abs(Cset{ind_2(i)}(2));
            if curr_min_y < min_y
                min_y = curr_min_y;
                R = new_Rset{i};
                t = [Cset{ind_2(i)}(1);0;Cset{ind_2(i)}(3)];
            end
        end
        % Filter five -> Restrict rotation only about the Y axis
        R(1,2) = 0;
        R(2,1) = 0;
        R(2,3) = 0;
        R(3,2) = 0;
        
        %%%%% Hack For now - 
        if abs(R(1,3)) < 0.001
            R(1,3) = 0;
        end
        if abs(R(3,1)) < 0.001
            R(3,1) = 0;
        end  
        
        % Filter four -> Limit the sideways movement
        if abs(t(1)) < 0 || R(1,1) > 0.99 % This implies the rotation is almost zero degrees
            t = [0;0;t(3)];
        end
    else
        R = eye(3);
        t = [0;0;0];
    end
else
    R = eye(3);
    t = [0;0;0];
end