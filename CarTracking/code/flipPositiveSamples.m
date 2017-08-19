thisfolder = '..\input\Dataset\vehicles\GTI_MiddleClose';
filePattern = sprintf('%s/*.png', thisfolder);
baseFileNames = dir(filePattern);
curr_file_names = {baseFileNames.name};
numberOfImageFiles = length(baseFileNames);
for i = 1 : numberOfImageFiles
    curr_file_name = cell2mat(curr_file_names(i));
    this_file_name = fullfile(thisfolder,curr_file_name);
    im = imread(this_file_name);
    I2 = flip(im ,2);           %# horizontal flip
    out_file_name = strcat('flip_',curr_file_name);
    out_full_file_name = fullfile(thisfolder, out_file_name);
    imwrite(I2, out_full_file_name);
    %I3 = flip(im ,1);           %# vertical flip
    %I4 = flip(I3,2);    %# horizontal+vertical flip
end
subplot(2,2,1), imshow(im)
subplot(2,2,2), imshow(I2)
%subplot(2,2,3), imshow(I3)
%subplot(2,2,4), imshow(I4)