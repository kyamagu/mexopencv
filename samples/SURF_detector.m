function SURF_detector
%SURF_DETECTOR  feature detector demo
%
% Before start, addpath('/path/to/mexopencv');
%

root = fileparts(fileparts(mfilename('fullpath')));
im = cv.cvtColor(imread(fullfile(root,'test','img001.jpg')),'RGB2GRAY');

detector = cv.FeatureDetector('SURF');
keypoints = detector.detect(im);

im_keypoints = cv.drawKeypoints(im,keypoints);
imshow(im_keypoints);

end
