function runmeforframes()
%% Start reading the video file
inpfilename = sprintf('../Input/detectbuoy.avi');
if exist(inpfilename, 'file')
    videoObject = VideoReader(inpfilename);
    numOfFrames = videoObject.NumberOfFrames;
    traindataFolder = sprintf('../Images/TrainingSet/Frames');
    testdatafolder = sprintf('../Images/TestSet/Frames');
%     if ~exist(traindataFolder, 'dir')
%         mkdir(traindataFolder);
%     end
    stepsize = 30;
    j = 1;
    for i = 1 : stepsize:numOfFrames 
        r = randi(stepsize*j,1,15);
        r = r + i;
        for frame = 1:numOfFrames
            outputBaseFileName = sprintf('Frame %d.jpg', frame);
            if any(r == frame)
                outputFullFileName = fullfile(traindataFolder, outputBaseFileName);
            else
                outputFullFileName = fullfile(testdatafolder, outputBaseFileName);
            end
            thisFrame = read(videoObject, frame);
            imwrite(thisFrame, outputFullFileName, 'jpg')
        end
        j = j + 1;
    end
end
end