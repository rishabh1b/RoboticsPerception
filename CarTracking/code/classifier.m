%% Get the training positive data and negative image data
datafolder = '..\input\Dataset';
positive = sprintf('vehicles');
negative= 'non-vehicles/all';

%define positive images
positiveFolder= fullfile(datafolder,positive);
positiveImages = imageDatastore(positiveFolder);

%define negative images
negativeFolder= fullfile(datafolder,negative);
%negativeImages = imageDatastore(negativeFolder,'IncludeSubfolders', true);
% imageDataStore will not work in 2016a, will need cell or string
positive_instances = getPositiveInstances(positiveFolder);
%% Run the classifier
trainCascadeObjectDetector('CarDetector.xml',positive_instances,negativeFolder,...
    'FalseAlarmRate',0.01,'NumCascadeStages',4);