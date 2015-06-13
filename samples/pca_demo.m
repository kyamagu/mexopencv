%% PCA demo
% An example using PCA for dimensionality reduction while maintaining an
% amount of variance.
%
% This program demonstrates how to use OpenCV PCA with a
% specified amount of variance to retain.
%
% The program takes as input a list of images.
% The author recommends using the first 15 faces of the AT&T face data set:
% http://www.cl.cam.ac.uk/research/dtg/attarchive/facedatabase.html
%
% <https://github.com/Itseez/opencv/blob/master/samples/cpp/pca.cpp>

%% Input images

% get the list of images
imgList = dir(fullfile(mexopencv.root(),'test','left*.jpg'));

% cell-array to hold the images
images = cell(numel(imgList),1);

% Read in the data.
for i=1:numel(imgList)
    images{i} = imread(fullfile(mexopencv.root(),'test',imgList(i).name));
end

% Quit if there are not enough images for this demo.
if numel(images) <= 1
    error(['This demo needs at least 2 images to work. ' ...
        'Please add more images to your data set!']);
end

display(images)

%% PCA
% Reshape and stack images into a row Matrix
data = zeros(numel(images), numel(images{1}));
for i=1:numel(images)
    data(i,:) = im2double(images{i}(:));
end

%%
% perform PCA
retVar = 95;
pca = cv.PCA(data, 'DataAs','Row', 'RetainedVariance',retVar/100);

%% Demonstration of the effect of retainedVariance on the first image

% project into the eigenspace, thus the image becomes a "point"
point = pca.project(data(i,:));

% re-create the image from the "point"
reconstruction = pca.backProject(point);

% reshape from a row vector into image shape
reconstruction = reshape(reconstruction, size(images{1}));

% re-scale for displaying purposes
reconstruction = im2uint8((reconstruction - min(reconstruction(:))) ./ range(reconstruction(:)));

% display result
imshow(reconstruction)
title('Reconstruction')
xlabel(sprintf('Retained Variance: %d%%, # of PCs: %d', ...
    retVar, size(pca.eigenvectors,1)))
snapnow
