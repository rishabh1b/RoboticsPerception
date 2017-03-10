function gmmmodel = EM(N, samples)
%% Fit a GMM and look at how good the computation is
gmmmodel = fitgmdist(double(samples), N);
end