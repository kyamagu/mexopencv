%% SURF Feature Detection demo
% SURF keypoint detection + keypoint drawing with OpenCV functions
%
% In this sample you will learn how to use the cv.FeatureDetector interface
% in order to find interest points. Specifically:
%
% * Use <matlab:doc('cv.SURF') cv.SURF> and its function cv.SURF.detect to
%   perform the detection process.
% * Use the function <matlab:doc('cv.drawKeypoints') cv.drawKeypoints> to draw
%   the detected keypoints.
%
% See also:
% <http://docs.opencv.org/3.0.0/d7/d66/tutorial_feature_detection.html>,
% <http://docs.opencv.org/3.0.0/df/dd2/tutorial_py_surf_intro.html>
%

%%
% Read image as grayscale
img = cv.imread(fullfile(mexopencv.root(),'test','butterfly.jpg'), ...
    'Grayscale',true);

%%
% Detect keypoints using SURF Detector
detector = cv.SURF();
detector.HessianThreshold = 400;
keypoints = detector.detect(img)

%%
% Draw keypoints
out = cv.drawKeypoints(img, keypoints);
imshow(out);

%%
% We increase the Hessian Threshold to some large value.
% This is just to avoid drawing too many keypoints.
% In real applications, it is better to have a value between 300 and 500,
% as we may need all those keypoints when matching.
detector.HessianThreshold = 50000;
keypoints = detector.detect(img)
out = cv.drawKeypoints(img, keypoints, ...
    'Color',[255 0 0], 'DrawRichKeypoints',true);
imshow(out);

%%
% Now we apply U-SURF, so that it won't find the orientation.
detector.Upright = true;
keypoints = detector.detect(img);
out = cv.drawKeypoints(img, keypoints, ...
    'Color',[255 0 0], 'DrawRichKeypoints',true);
imshow(out);
