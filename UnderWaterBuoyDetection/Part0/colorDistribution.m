function colorsamples = colorDistribution(filename_base, outputfilename)
%% For Red Buoy
%filename_base = '../../Images/TrainingSet/CroppedBuoys/R_';
colorsamples = [];
outputfolder = sprintf('../../Output/Part0');
for i = 1:16
    filename = sprintf('00%d.jpg',i);
    fullfilename = strcat(filename_base, filename);
    im = imread(fullfilename);
    im = im2double(im);
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    r_s = R(R > 0.9);
    g_s = G(R > 0.9);
    b_s = B(R > 0.9);
    colorsamples = [colorsamples;[r_s g_s b_s]];
    %R = medfilt2(R,[2 2]);
    %G = medfilt2(G,[2 2]);
    %B = medfilt2(B,[2 2]);
end
scatter3(colorsamples(:,1), colorsamples(:,2), colorsamples(:,3), '.')
pause(0.1)
hgexport(gcf, fullfile(outputfolder, outputfilename), hgexport('factorystyle'), 'Format', 'jpeg');
%% For Yellow buoy
%% Modify the output of the function to return the color samples for all the buoys