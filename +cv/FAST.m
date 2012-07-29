%FAST  Detects corners using the FAST algorithm
%
%    keypoints = cv.FAST(im)
%    keypoints = cv.FAST(im, 'OptionName', optionValue)
%
% ## Input
% * __im__ Image where keypoints (corners) are detected.
%
% ## Output
% * __keypoints__ Keypoints detected on the image.
%
% ## Options
% * __Threshold__ Threshold on difference between intensity of the central
%        pixel and pixels on a circle around this pixel. See the algorithm
%        description [E. Rosten, 2006]. default 20.
% * __NonMaxSupression__ If it is true, non-maximum supression is applied
%        to detected corners (keypoints). default true.
%
% Detects corners using the FAST algorithm by E. Rosten (Machine Learning
% for High-speed Corner Detection, 2006).
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
