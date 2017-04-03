function classifier = tsc()
% function to get the classifier data after suitable training.
% it assumes a cell_size of 8 for HOG features.
%% Get the image data stores
trainingDir = '..\training\subset_training';
%testingDir = '..\testing\subset_testing'; 
trainingSet = imageDatastore(trainingDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
%testingSet = imageDatastore(testingDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
%% confirm each Data set
%countEachLabel(trainingSet)
%countEachLabel(testingSet)
%% Classification using HOG-SVM 
%imhog = vl_hog('render', hog, 'verbose', 'variant', 'dalaltriggs') ;
%hog = vl_hog(im2single(img), cellsize);
%imhog = vl_hog('render', hog, 'verbose') ;
%clf ; imagesc(imhog) ; colormap gray ;
hogFeatureSize = 2304;%9216;%36864; %Size-8-4-2 respectively
numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

for i = 1:numImages
    img = readimage(trainingSet, i);
    img = rgb2gray(img);
    img = medfilt2(img, [3 3]);
    img = imresize(img, [64 64]);
    cellsize = 8;
    hog = vl_hog(im2single(img), cellsize,'variant', 'dalaltriggs') ;
    trainingFeatures(i, :) = hog(:)';
end

% Get labels for each image.
trainingLabels = trainingSet.Labels;
classifier = fitcecoc(trainingFeatures, trainingLabels);
%% Evaluate the Classifier
% numImages = numel(testingSet.Files);
% testFeatures = zeros(numImages, hogFeatureSize, 'single');
% testLabels = testingSet.Labels;
% 
% for i = 1:numImages
%     img = readimage(testingSet, i);
%     img = rgb2gray(img);
%     img = medfilt2(img, [3 3]);
%     img = imresize(img, [64 64]);
%     cellsize = 4;
%     hog = vl_hog(im2single(img), cellsize,'variant', 'dalaltriggs') ;
%     testFeatures(i, :) = hog(:)';
% end
% predictedLabels = predict(classifier, testFeatures);
% confMat = confusionmat(testLabels, predictedLabels);
end