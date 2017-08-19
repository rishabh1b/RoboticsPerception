%% Take 4 1D gaussians
mu_1 = 0;
mu_2 = 3;
mu_3 = 6;
mu_4 = 9;
sigma_1 = 2;
sigma_2 = 0.5;
sigma_3 = 3;
sigma_4 = 1.5;
%% Get samples from each of these
y_1 = normrnd(mu_1, sigma_1,[50,1]);
y_2 = normrnd(mu_2, sigma_2,[50,1]);
y_3 = normrnd(mu_3, sigma_3,[50,1]);
y_4 = normrnd(mu_4, sigma_4,[50,1]);
%% Sort the samples and plot it against mean of the three gaussians
X = sort([y_1;y_2;y_3;y_4]); % The samples
Y = (normpdf(X,mu_1,sigma_1) + normpdf(X,mu_2,sigma_2) + normpdf(X,mu_3,sigma_3) + normpdf(X,mu_4,sigma_4)) ./ 4;
plot(X,Y)
hold on
%% Fit a GMM and look at how good the computation is
gmmmodel = fitgmdist(X, 4);
Y_gmm = pdf(gmmmodel,X);
plot(X, Y_gmm, 'r')