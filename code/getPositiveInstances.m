% utility function for getting the struct of positive_instances required 
% by the function trainCascadeObjectDetector - R2016a
function positive_instances = getPositiveInstances(positiveFolder)
%% Start reading the training Data folders
allSubFolders = genpath(positiveFolder);
% Get folder names in a cell
listOfFolderNames = textscan( allSubFolders, '%s', 'delimiter', ';' );
[numberOfFolders ,~] = size(listOfFolderNames{1});
bbox = [1 1 64 64];
positive_instances = [];
% Process all image files in each of the folders.
for k = 2 : numberOfFolders
	thisfolder = listOfFolderNames{1}{k};
	fprintf('Processing folder %s\n', thisfolder);
	filePattern = sprintf('%s/*.png', thisfolder);
	baseFileNames = dir(filePattern);
    curr_file_names = {baseFileNames.name};
	numberOfImageFiles = length(baseFileNames);
    for i = 1 : numberOfImageFiles
        this_file_name = fullfile(thisfolder,cell2mat(curr_file_names(i)));
        field = 'imageFilename';
        value = {this_file_name};
        field_2 = 'objectBoundingBoxes';
        value_2 = {bbox};
        s = struct(field,value,field_2,value_2);
        positive_instances = [positive_instances;s];
    end
end
end

