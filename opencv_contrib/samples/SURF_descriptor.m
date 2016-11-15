%% SURF Feature Description demo
% SURF detector + descritpor + BruteForce/FLANN Matcher + drawing matches with OpenCV functions
%
% In this sample you will learn how to use the cv.DescriptorExtractor
% interface in order to find the feature vector correspondent to the
% keypoints. Specifically:
%
% * Use <matlab:doc('cv.SURF') cv.SURF> and its function cv.SURF.compute to
%   perform the required calculations.
% * Use either the |BFMatcher| to match the features vector, or the
%   |FlannBasedMatcher| in order to perform a quick and efficient matching by
%   using the Clustering and Search in Multi-Dimensional Spaces FLANN module.
% * Use the function <matlab:doc('cv.drawMatches') cv.drawMatches> to draw the
%   detected matches.
%
% <http://docs.opencv.org/3.1.0/d5/dde/tutorial_feature_description.html>
% <http://docs.opencv.org/3.1.0/d5/d6f/tutorial_feature_flann_matcher.html>
%

%% Images
% Prepare a pair of images
im1 = imread(fullfile(mexopencv.root(),'test','box.png'));
im2 = imread(fullfile(mexopencv.root(),'test','box_in_scene.png'));
subplot(121), imshow(im1), title('box')
subplot(122), imshow(im2), title('box-in-scene')

% some parameters
do_filtering = true;
minHessian = 400;

%% Detect
% Detect keypoints using SURF Detector
detector = cv.FeatureDetector('SURF', 'HessianThreshold',minHessian);
keypoints1 = detector.detect(im1)
keypoints2 = detector.detect(im2)

% specify a mask where to look for keypoints
if false
    mask = false(size(im2));
    mask(100:350,100:350) = true;
    keypoints2 = detector.detect(im2, 'Mask',mask);
end

%%
% Show distribution of keypoint sizes
if ~mexopencv.isOctave()
    %HACK: HISTOGRAM not implemented in Octave
    figure
    histogram([keypoints1.size]), hold on
    histogram([keypoints2.size])
    xlabel('Keypoint sizes'), ylabel('Count')
    legend('keypoints1', 'keypoints2')
    hold off
end

% Filter keypoints by size
if do_filtering
    keypoints1 = cv.KeyPointsFilter.runByKeypointSize(keypoints1, 0, 50);
    keypoints2 = cv.KeyPointsFilter.runByKeypointSize(keypoints2, 0, 50);
end

%%
% Show distribution of keypoint responses
if ~mexopencv.isOctave()
    %HACK: HISTOGRAM not implemented in Octave
    histogram([keypoints1.response]), hold on
    histogram([keypoints2.response])
    xlabel('Keypoint responses'), ylabel('Count')
    legend('keypoints1', 'keypoints2')
    hold off
end

% Filter keypoints by responses
if do_filtering
    keypoints1 = cv.KeyPointsFilter.retainBest(keypoints1, 500);
    keypoints2 = cv.KeyPointsFilter.retainBest(keypoints2, 500);
end

%%
figure
subplot(121), imshow(cv.drawKeypoints(im1, keypoints1))
subplot(122), imshow(cv.drawKeypoints(im2, keypoints2))

%% Compute
% Calculate descriptors (feature vectors) using SURF
extractor = cv.DescriptorExtractor('SURF');
descriptors1 = extractor.compute(im1, keypoints1);
descriptors2 = extractor.compute(im2, keypoints2);
whos descriptors*

%% Match
% Match descriptor vectors with a brute force matcher
%matcher = cv.DescriptorMatcher('BFMatcher', 'NormType','L2');
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors1, descriptors2)

if false
    % Match descriptor vectors using FLANN matcher
    matcher = cv.DescriptorMatcher('FlannBased');
    matches = matcher.radiusMatch(descriptors1, descriptors2, 0.22);
    matches = [matches{:}];
end

%%
% Show distribution of match distances
if ~mexopencv.isOctave()
    %HACK: HISTOGRAM not implemented in Octave
    figure
    histogram([matches.distance])
    xlabel('Match distances'), ylabel('Count')
end

% Filter matches by distance ("good" matches)
if do_filtering
    [~,idx] = sort([matches.distance]);
    idx = idx(1:min(50,end));
    matches = matches(idx);
    if false
        min_dist = min([matches.distance]);
        matches = matches([matches.distance] <= max(3*min_dist, 0.22));
    end
end

%%
% Draw matches
out = cv.drawMatches(im1, keypoints1, im2, keypoints2, matches);
figure, imshow(out);
