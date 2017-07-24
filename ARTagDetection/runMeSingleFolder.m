function runMeSingleFolder()
%% Start reading the Data folders
i = 0;
dataFolder = sprintf('../Data/Tag%d', i);
if exist(dataFolder, 'dir')
    outputFolder = sprintf('../Output/Tag%d', i);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    process_frames(dataFolder,outputFolder);
end      
end