%% Create Video From Frames
function CreateVideo(datafolder)

outputfolder=datafolder;
outputVideo = VideoWriter(fullfile(outputfolder,'Part0.mp4'),'MPEG-4');
outputVideo.FrameRate = 30;

open(outputVideo)
D = dir([datafolder,'/*.jpg']);
numOfFrames = length(D);
for k = 1:numOfFrames
    curr_file = sprintf('output_Frames %d.jpg',k);
    fullfilename = fullfile(datafolder,curr_file);
    if(~exist(fullfilename,'file'))
       continue;
    end
    im = imread(fullfilename);
    writeVideo(outputVideo,im)
end
close(outputVideo)
end