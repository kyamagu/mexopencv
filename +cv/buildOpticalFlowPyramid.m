%BUILDOPTICALFLOWPYRAMID  Constructs the image pyramid which can be passed to cv.calcOpticalFlowPyrLK
%
%    pyramid = cv.buildOpticalFlowPyramid(img)
%    [pyramid,maxLvl] = cv.buildOpticalFlowPyramid(img)
%    pyramid = cv.buildOpticalFlowPyramid(img, 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ 8-bit input image.
%
% ## Output
% * __pyramid__ output pyramid. A cell-array of matrices (pyramid levels),
%       interleaved with corresponding gradients if `WithDerivatives` flag
%       is true. Each gradient is a matrix of type `int16` of same size as
%       pyramid at that level with 2-channels.
% * __maxLvl__ number of levels in constructed pyramid. Can be less than
%       `MaxLevel`.
%
% ## Options
% * __WinSize__ window size of optical flow algorithm. Must be not less than
%       `WinSize` argument of cv.calcOpticalFlowPyrLK. It is needed to
%       calculate required padding for pyramid levels. default [21,21]
% * __MaxLevel__ 0-based maximal pyramid level number. default 3
% * __WithDerivatives__ set to precompute gradients for the every pyramid
%       level. If pyramid is constructed without the gradients then
%       cv.calcOpticalFlowPyrLK will calculate them internally. default true
% * __PyrBorder__ the border mode for pyramid layers. See cv.copyMakeBorder.
%       default 'Reflect101'
% * __DerivBorder__ the border mode for gradients. See cv.copyMakeBorder.
%       default 'Constant'
% * __TryReuseInputImage__ put ROI of input image into the pyramid if
%       possible. You can pass false to force data copying. default true
%
% See also: cv.calcOpticalFlowPyrLK, cv.buildPyramid
%
