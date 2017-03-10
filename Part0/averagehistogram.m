%% For Red Buoy
filename_base = '../../Images/TrainingSet/CroppedBuoys/G_';
bins = (0:1:255)';
avg_counts_r = zeros(256,1);
avg_counts_g = zeros(256,1);
avg_counts_b = zeros(256,1);
outputfolder = sprintf('../../Output/Part0');
n = 5;
for i = 1 : n
    filename = sprintf('00%d.jpg',i);
    fullfilename = strcat(filename_base, filename);
    im = imread(fullfilename);
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    %R = medfilt2(R,[1 1]);
    %G = medfilt2(G,[1 1]);
    %B = medfilt2(B,[1 1]);
    [r_c, ~] = imhist(R(R > 0));
    [g_c, ~] = imhist(G(G > 0));
    [b_c, ~] = imhist(B(B > 0));
    for j = 1 : 256
        avg_counts_r(j) = avg_counts_r(j) + r_c(j);
        avg_counts_g(j) = avg_counts_g(j) + g_c(j);
        avg_counts_b(j) = avg_counts_b(j) + b_c(j);
    end
end
avg_counts_r = avg_counts_r ./ n;
avg_counts_g = avg_counts_g ./ n;
avg_counts_b = avg_counts_b ./ n;
figure
%X = scatter3(avg_counts_r,avg_counts_g, avg_counts_b);
title('Histogram for Red colured buoy')
%subplot(3,1,1)
area(bins, avg_counts_r, 'FaceColor', 'r')
xlim([0 255])
hold on
%subplot(3,1,2)
area(bins, avg_counts_g, 'FaceColor', 'g')
%xlim([0 256])
%subplot(3,1,3)
area(bins, avg_counts_b, 'FaceColor', 'b')
%xlim([0 256])
hold off
pause(0.1)
hgexport(gcf, fullfile(outputfolder, 'G_hist.jpg'), hgexport('factorystyle'), 'Format', 'jpeg');
%% For Yellow buoy
filename_base = '../../Images/TrainingSet/CroppedBuoys/Y_';
bins = (0:1:255)';
avg_counts_r = zeros(256,1);
avg_counts_g = zeros(256,1);
avg_counts_b = zeros(256,1);
outputfolder = sprintf('../../Output/Part0');
for i = 1 : 16
    filename = sprintf('00%d.jpg',i);
    fullfilename = strcat(filename_base, filename);
    im = imread(fullfilename);
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    R = medfilt2(R,[2 2]);
    G = medfilt2(G,[2 2]);
    B = medfilt2(B,[2 2]);
    [r_c, ~] = imhist(R(R > 100));
    [g_c, ~] = imhist(G(R > 100));
    [b_c, ~] = imhist(G(R > 100));
    for j = 1 : 256
        avg_counts_r(j) = avg_counts_r(j) + r_c(j);
        avg_counts_g(j) = avg_counts_g(j) + g_c(j);
        avg_counts_b(j) = avg_counts_b(j) + b_c(j);
    end
end
avg_counts_r = avg_counts_r ./ 16;
avg_counts_g = avg_counts_g ./ 16;
avg_counts_b = avg_counts_b ./ 16;
figure
title('Histogram for Yellow colured buoy')
%subplot(3,1,1)
area(bins, avg_counts_r, 'FaceColor', 'r')
xlim([0 255])
hold on
%subplot(3,1,2)
area(bins, avg_counts_g, 'FaceColor', 'g')
xlim([0 255])
%subplot(3,1,3)
area(bins, avg_counts_b, 'FaceColor', 'b')
xlim([0 255])
pause(0.1)
%hgexport(gcf, fullfile(outputfolder, 'Y_hist.jpg'), hgexport('factorystyle'), 'Format', 'jpeg');