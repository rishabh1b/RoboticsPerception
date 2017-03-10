%% For Red Buoy
outputfilename = 'G_hist.jpg';
filename_base = '../../Images/TrainingSet/CroppedBuoys/G_';
colorsamples = [];
outputfolder = sprintf('../../Output/Part0');
for i = 1:5
    filename = sprintf('00%d.jpg',i);
    fullfilename = strcat(filename_base, filename);
    im = imread(fullfilename);
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    % For Green
    r_s = R(G > 180);
    g_s = G(G > 180);
    b_s = B(G > 180);
    % For Red
%     r_s = R(R > 100);
%     g_s = G(R > 100);
%     b_s = B(R > 100);
    % For Yellow
%       r_s = R(R > 200 & G > 200);
%       g_s = G(R > 200 & G > 200);
%       b_s = B(R > 200 & G > 200);
    colorsamples = [colorsamples;[r_s g_s b_s]];
    %R = medfilt2(R,[2 2]);
    %G = medfilt2(G,[2 2]);
    %B = medfilt2(B,[2 2]);
end
scatter3(colorsamples(:,1), colorsamples(:,2), colorsamples(:,3), '.')
pause(0.1)
%hgexport(gcf, fullfile(outputfolder, outputfilename), hgexport('factorystyle'), 'Format', 'jpeg');