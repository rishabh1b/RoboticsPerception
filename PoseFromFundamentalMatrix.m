function [Rset,Cset] = PoseFromFundamentalMatrix(F,K)
%% EssentialMatrixFromFundamentalMatrix
% Use the camera calibration matrix to esimate the Essential matrix
% Inputs:
%     K - size (3 x 3) camera calibration (intrinsics) matrix for both
%     cameras
%     F - size (3 x 3) fundamental matrix from EstimateFundamentalMatrix
% Outputs:
%     E - size (3 x 3) Essential matrix with singular values (1,1,0)
E = K'* F * K;
[u,~,v] = svd(E);
E = u * [1 0 0;0 1 0;0 0 0] * v';
E = E / norm(E);
[Cset, Rset] = ExtractCameraPose(E);
%w = [0 -1 0;1 0 0;0 0 1];
% R = u * w' * v';
% t_skew = v * w * [1 0 0;0 1 0;0 0 0] * v';
% t = [t_skew(3,2);-t_skew(3,1);t_skew(2,1)];
end
