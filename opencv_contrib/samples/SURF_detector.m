function SURF_detector
%SURF_DETECTOR  feature detector demo
%
% Before start, addpath('/path/to/mexopencv');
%

im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
im = cv.cvtColor(im,'RGB2GRAY');

detector = cv.FeatureDetector('SURF');
keypoints = detector.detect(im);

im_keypoints = cv.drawKeypoints(im,keypoints);
imshow(im_keypoints);

end
