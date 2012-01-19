%SIFT  Detects keypoints and computes SIFT descriptors for them
%
%    keypoints = cv.SIFT(im)
%    keypoints = cv.SIFT(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.SIFT(...)
%
% Input:
%   im: Input 8-bit grayscale image.
% Output:
%   keypoints: The output vector of keypoints.
%   descriptors: The output concatenated vectors of descriptors. Each descriptor
%       is a 128-element vector, as returned by SIFT::descriptorSize(). So
%       the total size of descriptors will be keypoints.size()*descriptorSize().
% Options:
%   'NOctaves': The number of a gaussian pyramid octaves that the detector uses.
%       It is set to 4 by default. If you want to get very large features, use
%       the larger value. If you want just small features, decrease it.
%   'NOctaveLayers': The number of images within each octave of a gaussian
%       pyramid. It is set to 2 by default.
%   'FirstOctave': default -1
%   'AngleMode': 0 = FIRST_ANGLE or 1 = AVERAGE_ANGLE. default 0
%   'Threshold': default 0.04 / (NOctaveLayers * 2.0)
%   'EdgeThreshold': default 10.0
%   'Magnification': default 3.0
%   'IsNormalize': default true
%   'RecalculateAngles': default true
%   'Mask': Optional input mask that marks the regions where we should detect
%        features
%
% Extracts keypoints and computing descriptors using the Scale Invariant
% Feature Transform (SIFT) approach.
%