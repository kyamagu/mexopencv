%ORB  Detects keypoints and computes ORB descriptors for them
%
%    keypoints = cv.ORB(im)
%    keypoints = cv.ORB(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.ORB(...)
%
% Input:
%   im: Input 8-bit grayscale image.
% Output:
%   keypoints: The output vector of keypoints.
%   descriptors: The output concatenated vectors of descriptors. Each descriptor
%       is a 128-element vector, as returned by ORB::descriptorSize(). So
%       the total size of descriptors will be keypoints.size()*descriptorSize().
% Options:
%   'NFeatures': the number of desired features. default 500
%   'ScaleFactor': default 1.2
%   'NLevels': default 3
%   'EdgeThreshold': default 31
%   'FirstLevel': default 0
%   'Mask': Optional input mask that marks the regions where we should detect
%        features
%
% Extracts ORB features and descriptors from an image.
%