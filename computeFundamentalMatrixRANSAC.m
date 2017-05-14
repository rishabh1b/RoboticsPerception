function F = computeFundamentalMatrixRANSAC(matchedpoints1, matchedpoints2)
global thresh;
thresh = 3; %Pixels;
F = zeros(3,3);
n = 0;
N = 2000;
p = 0.95;
sz = int32(size(matchedpoints1,1));
old_score = getFitnessScore(F, matchedpoints1.Location, matchedpoints2.Location);
chosen_pt_ind = [];
while n < N
    %Select 8 Points at random
    ind = randi(sz,1,8);
    x1 = matchedpoints1(ind);
    x2 = matchedpoints2(ind);
    f = EstimateFundamentalMatrix(x1.Location, x2.Location);
    [new_score, chosen_ind] = getFitnessScore(f,matchedpoints1.Location, matchedpoints2.Location);
    if  new_score > old_score
        F = f;
        chosen_pt_ind = chosen_ind;
        N = min(N,log(1-p) / log(1 - new_score^8));
        old_score = new_score;
    end
    n = n + 1;
end
%Compute fundamental matrix using best fundamental matrix
% x1 = matchedpoints1(chosen_pt_ind);
% x2 = matchedpoints2(chosen_pt_ind);
% F = EstimateFundamentalMatrix(x1.Location, x2.Location);
end
