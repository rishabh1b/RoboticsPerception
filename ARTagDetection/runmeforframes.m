function runmeforframes()
%% Setup the Paths
% baseinputdir = '..\Input';
% baseoutputdir = '..\Output';
% basedatadir = '..\Data';
%% Start reading the video files
for i = 2:15
    inpfilename = sprintf('../Input/Tag%d.mp4', i);
    if exist(inpfilename, 'file')
        videoObject = VideoReader(inpfilename);
        numOfFrames = videoObject.NumberOfFrames;
        dataFolder = sprintf('../Data/Tag%d', i);
        if ~exist(dataFolder, 'dir')
            mkdir(dataFolder);
        end

        for frame = 1:numOfFrames
            outputBaseFileName = sprintf('Frame %d.jpg', frame);
            outputFullFileName = fullfile(dataFolder, outputBaseFileName);
            thisFrame = read(videoObject, frame);
            imwrite(thisFrame, outputFullFileName, 'jpg')
        end
        %D = dir([dataFolder,'\*.jpg']);
        outputFolder = sprintf('../Output/Tag%d', i);
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        %marker_id = process_frames(dataFolder,outputFolder);
        %fprintf('The id of the tag in tag%d.mp4 is %d \n', i, marker_id);
    end
        
end
end