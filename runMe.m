function runMe()
%% Start reading the Data folders
%Code for reading folders inspired from -
%https://www.mathworks.com/matlabcentral/answers/uploaded_files/9333/recurse_subfolders.m
dataFolder = sprintf('../Data/');
allSubFolders = genpath(dataFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

% Process all image files in those folders.
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisfolder = listOfFolderNames{k};
    if strcmp(thisfolder,'../Data/multipletags')
        continue;
    end
	fprintf('Processing folder %s\n', thisfolder);
    
	filePattern = sprintf('%s/*.jpg', thisfolder);
	baseFileNames = dir(filePattern);
	numberOfImageFiles = length(baseFileNames);
    if numberOfImageFiles > 0
        A = strsplit(thisfolder, '\');
        outputFolder = sprintf('../Output/%s', cell2mat(A(3)));
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        process_frames(thisfolder,outputFolder); 
    end
end