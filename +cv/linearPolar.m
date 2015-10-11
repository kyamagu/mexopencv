%LINEARPOLAR  Remaps an image to polar space
%
%    dst = cv.linearPolar(src, center, maxRadius)
%    dst = cv.linearPolar(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __center__ The transformation center.
% * __maxRadius__ Inverse magnitude scale parameter.
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
%    rho = (size(src,2) / maxRadius) * sqrt(x^2 + y^2)
%    phi = atan(y/x)
%
% See also: cv.logPolar
%
