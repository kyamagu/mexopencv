%% SURF Feature Description demo

%%
% Prepare a pair of images
im1 = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
im1 = cv.cvtColor(im1,'RGB2GRAY');
im2 = fliplr(im1);

%%
% Detect keypoints using SURF Detector
detector = cv.FeatureDetector('SURF');
keypoints1 = detector.detect(im1);
keypoints2 = detector.detect(im2);

%%
% Calculate descriptors (feature vectors)
extractor = cv.DescriptorExtractor('SURF');
descriptors1 = extractor.compute(im1,keypoints1);
descriptors2 = extractor.compute(im1,keypoints2);

%%
% Match descriptor vectors with a brute force matcher
matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors1,descriptors2);

%%
% Draw matches
im_matches = cv.drawMatches(im1, keypoints1, im2, keypoints2, matches);
imshow(im_matches);
