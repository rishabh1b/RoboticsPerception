function runmeforframes()
% Utility Function to generate frames from a given video sequence
%% Start reading the video files
inpfilename = sprintf('../input/project_video.mp4');
if exist(inpfilename, 'file')
    videoObject = VideoReader(inpfilename);
    numOfFrames = videoObject.NumberOfFrames;
    dataFolder = sprintf('../Data/normal');
    if ~exist(dataFolder, 'dir')
        mkdir(dataFolder);
    end

    for frame = 1:numOfFrames
        outputBaseFileName = sprintf('Frame %d.jpg', frame);
        outputFullFileName = fullfile(dataFolder, outputBaseFileName);
        thisFrame = read(videoObject, frame);
        imwrite(thisFrame, outputFullFileName, 'jpg')
    end
    outputFolder = sprintf('../output/project_video');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
end
end