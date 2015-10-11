%LOGPOLAR  Remaps an image to log-polar space
%
%    dst = cv.logPolar(src, center, M)
%    dst = cv.logPolar(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __center__ The transformation center; where the output precision is
%       maximal.
% * __M__ Magnitude scale parameter.
%
% ## Output
% * __dst__ Destination image, same size and type as `src`.
%
% ## Options
% * __Interpolation__ Interpolation method, default 'Linear'. One of:
%       * __Nearest__ nearest neighbor interpolation
%       * __Linear__ bilinear interpolation
%       * __Cubic__ bicubic interpolation
%       * __Lanczos4__ Lanczos interpolation over 8x8 neighborhood
% * __FillOutliers__ flag, fills all of the destination image pixels. If some
%       of them correspond to outliers in the source image, they are set to
%       zero. default true
% * __InverseMap__ flag, inverse transformation, default false. For example,
%       polar transforms:
%       * flag is not set: Forward transformation `dst(phi,rho) = src(x,y)`
%       * flag is set: Inverse transformation `dst(x,y) = src(phi,rho)`
%
% Transforms the source image using the following transformation:
%
%    dst(phi,rho) = src(x,y)
%
% where:
%
%    rho = M * log(sqrt(x^2 + y^2))
%    phi = atan(y/x)
%
% The function emulates the human "foveal" vision and can be used for fast
% scale and rotation-invariant template matching, for object tracking and so
% forth.
%
% See also: cv.linearPolar
%
