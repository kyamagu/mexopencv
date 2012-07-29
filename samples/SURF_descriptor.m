function SURF_descriptor
%SURF_DETECTOR  feature detector demo
%
% Before start, addpath('/path/to/mexopencv');
%

root = fileparts(fileparts(mfilename('fullpath')));
im1 = cv.cvtColor(imread(fullfile(root,'test','img001.jpg')),'RGB2GRAY');
im2 = fliplr(im1);

detector = cv.FeatureDetector('SURF');
keypoints1 = detector.detect(im1);
keypoints2 = detector.detect(im2);

extractor = cv.DescriptorExtractor('SURF');
descriptors1 = extractor.compute(im1,keypoints1);
descriptors2 = extractor.compute(im1,keypoints2);

matcher = cv.DescriptorMatcher('BruteForce');
matches = matcher.match(descriptors1,descriptors2);

im_matches = cv.drawMatches(im1, keypoints1, im2, keypoints2, matches);
imshow(im_matches);

end
