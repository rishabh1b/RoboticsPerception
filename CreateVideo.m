%% Create Video From Frames
function CreateVideo(datafolder, filename)
outputfolder=datafolder;
outputVideo = VideoWriter(fullfile(outputfolder,filename),'MPEG-4');
outputVideo.FrameRate = 30;

open(outputVideo)
filePattern = sprintf('%s/*.png', datafolder);
baseFileNames = dir(filePattern);
curr_file_names = {baseFileNames.name};
numberOfImageFiles = length(baseFileNames);
for k = 1:numberOfImageFiles
    fullfilename = fullfile(datafolder,cell2mat(curr_file_names(k)));
    if(~exist(fullfilename,'file'))
       continue;
    end
    im = imread(fullfilename);
    im = demosaic(im,'gbrg');
    writeVideo(outputVideo,im)
end
close(outputVideo)
end