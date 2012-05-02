%SIFT  Detects keypoints and computes SIFT descriptors for them
%
%    keypoints = cv.SIFT(im)
%    keypoints = cv.SIFT(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.SIFT(...)
%
% ## Input
% * __im__ Input 8-bit grayscale image.
%
% ## Output
% * __keypoints__ The output vector of keypoints.
% * __descriptors__ The output concatenated vectors of descriptors. Each descriptor
%       is a 128-element vector, as returned by SIFT::descriptorSize(). So
%       the total size of descriptors will be keypoints.size()*descriptorSize().
%
% ## Options
% * __NOctaves__ The number of a gaussian pyramid octaves that the detector uses.
%       It is set to 4 by default. If you want to get very large features, use
%       the larger value. If you want just small features, decrease it.
% * __NOctaveLayers__ The number of images within each octave of a gaussian
%       pyramid. It is set to 2 by default.
% * __FirstOctave__ default -1
% * __AngleMode__ 0 = FIRST\_ANGLE or 1 = AVERAGE\_ANGLE. default 0
% * __ConstrastThreshold__ default 0.04 / (NOctaveLayers * 2.0)
% * __EdgeThreshold__ default 10.0
% * __Magnification__ default 3.0
% * __IsNormalize__ default true
% * __RecalculateAngles__ default true
% * __Mask__ Optional input mask that marks the regions where we should detect
%        features
%
% Extracts keypoints and computing descriptors using the Scale Invariant
% Feature Transform (SIFT) approach.
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
