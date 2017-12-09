%WEIGHTEDMEDIANFILTER  Applies weighted median filter to an image
%
%     dst = cv.weightedMedianFilter(src, joint)
%     dst = cv.weightedMedianFilter(src, joint, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit or floating-point, 1-channel or 3-channel image.
% * __joint__ Joint 8-bit, 1-channel or 3-channel image.
%
% ## Output
% * __dst__ Destination image of the same size and type as `src`.
%
% ## Options
% * __Radius__ Radius of filtering kernel, should be a positive integer.
%   Default 7
% * __Sigma__ Filter range standard deviation for the joint image.
%   Default 25.5
% * __WeightType__ The type of weight definition. Specifies weight types of
%   weighted median filter, default 'EXP'. One of:
%   * __EXP__ `exp(-|I1-I2|^2 / (2*sigma^2))`
%   * __IV1__ `(|I1-I2| + sigma)^-1`
%   * __IV2__ `(|I1-I2|^2 + sigma^2)^-1`
%   * __COS__ `dot(I1,I2) / (|I1|*|I2|)`
%   * __JAC__ `(min(r1,r2) + min(g1,g2) + min(b1,b2)) / (max(r1,r2) + max(g1,g2) + max(b1,b2))`
%   * __OFF__ unweighted
% * __Mask__ A 0-1 mask that has the same size with `I`. This mask is used to
%   ignore the effect of some pixels. If the pixel value on mask is 0, the
%   pixel will be ignored when maintaining the joint-histogram. This is useful
%   for applications like optical flow occlusion handling. Not set by default.
%
% For more details about this implementation, please see [zhang2014100+].
%
% ## References
% [zhang2014100+]:
% > Qi Zhang, Li Xu, and Jiaya Jia. "100+ Times Faster Weighted Median Filter
% > (WMF)". In Computer Vision and Pattern Recognition (CVPR), 2014 IEEE
% > Conference on, pages 2830-2837. IEEE, 2014.
%
% See also: cv.medianBlur, cv.jointBilateralFilter
%
