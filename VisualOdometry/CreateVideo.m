%% Create Video From Frames
function CreateVideo(datafolder, filename)
outputfolder=datafolder;
outputVideo = VideoWriter(fullfile(outputfolder,filename),'MPEG-4');
outputVideo.FrameRate = 30;

open(outputVideo)
%filePattern = sprintf('%s/*.jpg', datafolder);
D = dir([datafolder,'\*.jpg']);
%baseFileNames = dir(filePattern);
%curr_file_names = {baseFileNames.name};
%numberOfImageFiles = length(baseFileNames);
numOfFrames = length(D);
for k = 1:numOfFrames
    curr_file = sprintf('im_vo_%d.jpg',k);
    fullfilename = fullfile(datafolder,curr_file);
    if(~exist(fullfilename,'file'))
       continue;
    end
    im = imread(fullfilename);
    %im = demosaic(im,'gbrg');
    writeVideo(outputVideo,im)
end
close(outputVideo)
end