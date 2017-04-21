%% https://www.mathworks.com/matlabcentral/answers/uploaded_files/23754/recurse_subfolders.m
datafolder = '..\input\Dataset';

positive = sprintf('vehicles');
negative= sprintf('non-vehicles');

%define positive images
positiveFolder= fullfile(datafolder,positive);
%allpositiveFolders = genpath(positiveFolder);
positiveImages = imageDatastore(positiveFolder);

%define negative images
negativeFolder= fullfile(datafolder,negative);
%allnegativeFolders = genpath(negativeFolder);
negativeImages = imageDatastore(negativeFolder);

%TODO: Will have to modify positiveImages to a mat file(struct/char)
%train images
trainCascadeObjectDetector('CarDetector.xml',positiveImages,negativeImages,...
    'FalseAlarmRate',0.1,'NumCascadeStages',5)