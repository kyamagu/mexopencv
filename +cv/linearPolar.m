%LINEARPOLAR  Remaps an image to polar coordinates space
%
%     dst = cv.linearPolar(src, center, maxRadius)
%     dst = cv.linearPolar(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __center__ The transformation center.
% * __maxRadius__ The radius of the bounding circle to transform. It
%   determines the inverse magnitude scale parameter too.
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
% Transform the source image using the following transformation:
%
%     dst(rho,phi) = src(x,y)
%     size(dst) <- size(src)
%
% where:
%
%     I = (dx,dy) = (x-center(2), y-center(1))
%     rho = Kx * magnitude(I)
%     phi = Ky * angle(I)_{0..360 deg}
%
% and:
%
%     Kx = size(src,2) / maxRadius
%     Ky = size(src,1) / 360
%
% Polar remaps reference:
%
% ![image](https://docs.opencv.org/3.3.1/polar_remap_doc.png)
%
% Note: To calculate magnitude and angle in degrees, cv.cartToPolar is used
% internally thus angles are measured from 0 to 360 with accuracy about 0.3
% degrees.
%
% See also: cv.logPolar, cv.remap
%
