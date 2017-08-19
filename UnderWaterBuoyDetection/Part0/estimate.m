function modelparams = estimate(colorsamples, color)
%color samples -> n x 3 array consisting of pixel value of the selected samples
%color - expects 1,2 or 3. 1 == RED, 2 == GREEN, 3 == YELLOW
if color == 1
    outputgaussfilename = '../..Output/Part0/R_gauss1D.jpg';
    curr_sample = double(colorsamples(:,1));
elseif color == 2
    outputgaussfilename = '../..Output/Part0/G_gauss1D.jpg';
    curr_sample = double(colorsamples(:,2));
else
    outputgaussfilename = '../..Output/Part0/Y_gauss1D.jpg';
    curr_sample = (double(colorsamples(:,1)) + double(colorsamples(:,2)) ./ 2);
end
mu = mean(curr_sample);
var = std(curr_sample)^2;
max_value = max(curr_sample);
min_value = min(curr_sample);
step = (max_value - min_value) / 1000;
Y = normpdf(min_value:step:max_value, mu, var);
%plot(min_value:step:max_value, Y);

%lot(curr_sample, Y)
modelparams = [mu, var];
end  
