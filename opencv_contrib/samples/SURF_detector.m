%% SURF Feature Detection demo

%%
% Read image and convert it to grayscale
im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
im = cv.cvtColor(im,'RGB2GRAY');

%%
% Detect keypoints using SURF Detector
detector = cv.FeatureDetector('SURF');
keypoints = detector.detect(im);

%%
% Draw keypoints
im_keypoints = cv.drawKeypoints(im,keypoints);
imshow(im_keypoints);
