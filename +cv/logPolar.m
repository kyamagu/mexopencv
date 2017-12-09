%LOGPOLAR  Remaps an image to semilog-polar coordinates space
%
%     dst = cv.logPolar(src, center, M)
%     dst = cv.logPolar(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __center__ The transformation center; where the output precision is
%   maximal.
% * __M__ Magnitude scale parameter. It determines the radius of the bounding
%   circle to transform too
%
% ## Output
% * __dst__ Destination image. It will have same size and type as `src`.
%
% ## Options
% * __Interpolation__ Interpolation method, default 'Linear'. One of:
%   * __Nearest__ nearest neighbor interpolation
%   * __Linear__ bilinear interpolation
%   * __Cubic__ bicubic interpolation
%   * __Lanczos4__ Lanczos interpolation over 8x8 neighborhood
% * __FillOutliers__ flag, fills all of the destination image pixels. If some
%   of them correspond to outliers in the source image, they are set to zero.
%   default true
% * __InverseMap__ flag, inverse transformation, default false. For example,
%   polar transforms:
%   * flag is not set: Forward transformation `dst(rho,phi) = src(x,y)`
%   * flag is set: Inverse transformation `dst(x,y) = src(rho,phi)`
%
% Transform the source image using the following transformation
% (See reference image in cv.linearPolar function):
%
%     dst(rho,phi) = src(x,y)
%     size(dst) <- size(src)
%
% where:
%
%     I = (dx,dy) = (x-center(2), y-center(1))
%     rho = M * log(magnitude(I))
%     phi = Ky * angle(I)_{0..360 deg}
%
% and:
%
%     M = size(src,2) / log(maxRadius)
%     Ky = size(src,1) / 360
%
% The function emulates the human "foveal" vision and can be used for fast
% scale and rotation-invariant template matching, for object tracking and so
% forth.
%
% Note: To calculate magnitude and angle in degrees, cv.cartToPolar is used
% internally thus angles are measured from 0 to 360 with accuracy about
% 0.3 degrees.
%
% See also: cv.linearPolar, cv.remap
%
