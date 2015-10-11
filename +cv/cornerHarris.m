%CORNERHARRIS  Harris corner detector
%
%    dst = cv.cornerHarris(src)
%    dst = cv.cornerHarris(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input single-channel 8-bit or floating-point image.
%
% ## Output
% * __dst__ Image to store the Harris detector responses. It has the type
%       `single` and the same size as `src` (single-channel).
%
% ## Options
% * __BlockSize__ Neighborhood size (see the details on
%       cv.cornerEigenValsAndVecs). default 5.
% * __KSize__ Aperture parameter for the cv.Sobel operator. default 3.
% * __K__ Harris detector free parameter. See the formula below. default 0.04
% * __BorderType__ Pixel extrapolation method. default 'Default'
%
% The function runs the Harris corner detector on the image. Similarly to
% cv.cornerMinEigenVal and cv.cornerEigenValsAndVecs, for each pixel `(x,y)`
% it calculates a `2 x 2` gradient covariance matrix `M(x,y)` over a
% `BlockSize x BlockSize` neighborhood. Then, it computes the following
% characteristic:
%
%     dst(x,y) = det(M(x,y)) - k * (trace(M(x,y)))^2
%
% Corners in the image can be found as the local maxima of this response map.
%
% See also: cv.cornerEigenValsAndVecs, cv.cornerMinEigenVal,
%  corner, cornermetric, detectHARRISFeatures
%
