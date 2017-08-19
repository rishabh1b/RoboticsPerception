function modelparams = estimate(colorsamples, color)
if color == 1
    outputgaussfilename = '../..Output/Part0/R_gauss3D.jpg';
elseif color == 2
    outputgaussfilename = '../..Output/Part0/G_gauss3D.jpg';
else
    outputgaussfilename = '../..Output/Part0/Y_gauss3D.jpg';
end
mu = mean(colorsamples);
standard_deviation = (std(double(colorsamples)));

std_r = standard_deviation(1);
std_g = standard_deviation(2);
std_b = standard_deviation(3);
n = numel(colorsamples(:,1));
cov_rg = sum((colorsamples(:,1) - mu(1)).* (colorsamples(:,2) - mu(2)))/ n;
cov_rb = sum((colorsamples(:,1) - mu(1)).* (colorsamples(:,3) - mu(3)))/ n;
cov_gb = sum((colorsamples(:,2) - mu(2)).* (colorsamples(:,3) - mu(3)))/ n;
sigma = [std_r^2 cov_rg cov_rb
         cov_rg std_g^2 cov_gb
         cov_rb cov_gb std_b^2];
field = 'mu';
value = mu;
field2 = 'sigma';
value2 = sigma;
modelparams = struct(field,value,field2,value2);
%% Plot a 3D Gaussian?