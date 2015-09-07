%CANNY  Finds edges in an image using the Canny algorithm
%
%    edges = cv.Canny(image, thresh)
%    edges = cv.Canny(image, thresh, 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ 8-bit input image (grayscale or color image).
% * __thresh__ Threshold for the hysteresis procedure. Scalar or 2-element
%       vector `[low_thresh,high_thresh]`.
%
% ## Output
% * __edges__ Output edge map; single channels 8-bit image, which has the
%       same size as `image`.
%
% ## Options
% * __ApertureSize__ Aperture size for the Sobel operator. Default 3
% * __L2Gradient__ Flag indicating whether a more accurate L2 norm
%       `sqrt((dI/dx)^2 + (dI/dy)^2)` should be used to compute the image
%       gradient magnitude (`L2gradient=true`), or whether the default L1 norm
%       `abs(dI/dx) + abs(dI/dy)` is enough (`L2gradient=false`).
%       Default false
%
% The function finds edges in the input image image and marks them in the output
% map edges using the Canny algorithm. When `thresh` is 2-element vector, the
% smallest value between them is used for edge linking. The largest value is
% used to find initial segments of strong edges. When `thresh` is a scalar, it is
% treated as a higher threshold value and `0.4*thresh` is used for the lower
% threshold. See http://en.wikipedia.org/wiki/Canny_edge_detector
%
% ## References
% [Canny86]:
% > John Canny. A computational approach to edge detection.
% > Pattern Analysis and Machine Intelligence, IEEE Transactions on,
% > (6):679-698, 1986.
%
% See also: cv.threshold, edge
%
