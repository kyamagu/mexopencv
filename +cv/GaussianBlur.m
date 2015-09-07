%GAUSSIANBLUR  Smoothes an image using a Gaussian filter
%
%    dst = cv.GaussianBlur(src)
%    dst = cv.GaussianBlur(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image; the image can have any number of channels, which are
%       processed independently, but the depth should be `uint8`, `uint16`,
%       `int16`, `single` or `double`.
%
% ## Output
% * __dst__ output image of the same size and type as `src`.
%
% ## Options
% * __KSize__ Gaussian kernel size. `KSize(1)` and `KSize(2)` can differ
%       but they both must be positive and odd. Or, they can be zeros and they
%       are computed from `SigmaX` and `SigmaY`. default [5,5]
% * __SigmaX__ Gaussian kernel standard deviation in X direction. default 0
% * __SigmaY__ Gaussian kernel standard deviation in Y direction. If `SigmaY`
%       is zero, it is set to be equal to `SigmaX`. If both sigmas are zeros,
%       they are computed from `KSize(2)` and `KSize(1)`, respectively (see
%       cv.getGaussianKernel for details). To fully control the result
%       regardless of possible future modifications of all this semantics, it
%       is recommended to specify all of `KSize`, `SigmaX`, and `SigmaY`.
%       default 0
% * __BorderType__ Pixel extrapolation method, see cv.copyMakeBorder.
%       default 'Default'
%
% The function convolves the source image with the specified Gaussian kernel.
%
% See also: cv.sepFilter2D, cv.filter2D, cv.blur, cv.boxFilter,
%  cv.bilateralFilter, cv.medianBlur
%
