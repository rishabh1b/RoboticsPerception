function F = EstimateFundamentalMatrix(x1, x2)
%% EstimateFundamentalMatrix
% Estimate the fundamental matrix from two image point correspondences 
% using normalized 8-point correspondence
% Inputs:
%     x1 - size (N x 2) matrix of points in image 1
%     x2 - size (N x 2) matrix of points in image 2, each row corresponding
%       to x1
% Output:
%    F - size (3 x 3) fundamental matrix with rank 2

sz = size(x1,1);
% Normalize the Image points
x1_x = x1(:,1);
x2_x = x2(:,1);
x1_y = x1(:,2);
x2_y = x2(:,2);

%First Transform
cent_x1_x = mean(x1_x);
cent_x1_y = mean(x1_y);
x1_x = x1_x - cent_x1_x * ones(sz,1);
x1_y = x1_y - cent_x1_y * ones(sz,1);
avg_dist = sqrt(sum(x1_x.^2  + x1_y.^2)) / sz;
scaling_factor = sqrt(2) / avg_dist;
x1(:,1) = scaling_factor * x1_x;
x1(:,2) = scaling_factor * x1_y;
dx = (-scaling_factor*cent_x1_x);
dy = (-scaling_factor*cent_x1_y);

T_1 = [scaling_factor,0,dx;0,scaling_factor,dy;0,0,1];  
%Second Transform
cent_x2_x = mean(x2_x);
cent_x2_y = mean(x2_y);
x2_x = x2_x - cent_x2_x * ones(sz,1);
x2_y = x2_y - cent_x2_y * ones(sz,1);
avg_dist = sqrt(sum(x2_x.^2  + x2_y.^2)) / sz;
scaling_factor = sqrt(2) / avg_dist;
x2(:,1) = scaling_factor * x2_x;
x2(:,2) = scaling_factor * x2_y;
T_2 = [scaling_factor 0 -scaling_factor*cent_x2_x;
       0 scaling_factor -scaling_factor*cent_x2_y;
       0 0 1];

%A_Mat = [A(:,1).* B(:,1) A(:,1).* B(:,2) A(:,1) A(:,2).* B(:,1) A(:,2) .* B(:,2) A(:,2) B(:,1) B(:,2) ones(8,1)];
A_Mat = [x1(:,1).* x2(:,1) x1(:,1).* x2(:,2) x1(:,1) x1(:,2).* x2(:,1) x1(:,2) .* x2(:,2) x1(:,2) x2(:,1) x2(:,2) ones(size(x1,1),1)];
[~,~,v] = svd(A_Mat);
F_lin = v(:,end);
F_rank3 =reshape(F_lin,3,3);
F_rank3 = F_rank3 / norm(F_rank3);
[u,d,v] = svd(F_rank3);
d(3,3) = 0;
F_rank2 = u * d * v';
F = T_2' * F_rank2 * T_1;
end

