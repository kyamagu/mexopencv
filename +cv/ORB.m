%ORB  Detects keypoints and computes ORB descriptors for them
%
%    keypoints = cv.ORB(im)
%    keypoints = cv.ORB(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.ORB(...)
%
% ## Input
% * __im__ Input 8-bit grayscale image.
%
% ## Output
% * __keypoints__ The output vector of keypoints.
% * __descriptors__ The output concatenated vectors of descriptors. Each descriptor
%       is a 128-element vector, as returned by ORB::descriptorSize(). So
%       the total size of descriptors will be keypoints.size()*descriptorSize().
%
% ## Options
% * __NFeatures__ the number of desired features. default 500
% * __ScaleFactor__ default 1.2
% * __NLevels__ default 3
% * __EdgeThreshold__ default 31
% * __FirstLevel__ default 0
% * __Mask__ Optional input mask that marks the regions where we should detect
%        features
%
% Extracts ORB features and descriptors from an image.
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
