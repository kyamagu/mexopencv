%HOUGHCIRCLES  Finds circles in a grayscale image using the Hough transform
%
%    circles = cv.HoughCircles(image)
%    circles = cv.HoughCircles(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ 8-bit, single-channel, grayscale input image.
%
% ## Output
% * __circles__ Output vector of found circles. A cell-array of 3-element
%       floating-point vectors `{[x, y, radius], ...}`.
%
% ## Options
% * __Method__ Detection method. Currently, the only implemented method is
%       'Gradient' (default). One of:
%       * __Standard__ classical or standard Hough transform. Every line is
%             represented by two floating-point numbers `(rho,theta)`, where
%             `rho` is a distance between `(0,0)` point and the line, and
%             `theta` is the angle between x-axis and the normal to the line.
%             Thus, the matrix must be (the created sequence will be) of
%             `single` type with 2-channels.
%       * __Probabilistic__ probabilistic Hough transform (more efficient in
%             case if the picture contains a few long linear segments). It
%             returns line segments rather than the whole line. Each segment
%             is represented by starting and ending points, and the matrix
%             must be (the created sequence will be) of the `int32` type with
%             4-channels.
%       * __MultiScale__ multi-scale variant of the classical Hough transform.
%             The lines are encoded the same way as 'Standard'.
%       * __Gradient__ basically 21HT, described in [Yuen90].
% * __DP__ Inverse ratio of the accumulator resolution to the image resolution.
%       For example, if `DP=1`, the accumulator has the same resolution as
%       the input image. If `DP=2`, the accumulator has half as big width
%       and height. default 1.
% * __MinDist__ Minimum distance between the centers of the detected circles.
%       If the parameter is too small, multiple neighbor circles may be
%       falsely detected in addition to a true one. If it is too large, some
%       circles may be missed. default `size(image,1)/8`.
% * __Param1__ First method-specific parameter. In case of 'Gradient', it is
%       the higher threshold of the two passed to the cv.Canny edge detector
%       (the lower one is twice smaller). default 100.
% * __Param2__ Second method-specific parameter. In case of 'Gradient', it is
%       the accumulator threshold for the circle centers at the detection
%       stage. The smaller it is, the more false circles may be detected.
%       Circles, corresponding to the larger accumulator values, will be
%       returned first. default 100.
% * __MinRadius__ Minimum circle radius. default 0.
% * __MaxRadius__ Maximum circle radius. default 0.
%
% The function finds circles in a grayscale image using a modification of the
% Hough transform.
%
% ## Note
% Usually the function detects the centers of circles well. However, it may
% fail to find correct radii. You can assist to the function by specifying the
% radius range (`MinRadius` and `MaxRadius`) if you know it. Or, you may
% ignore the returned radius, use only the center, and find the correct radius
% using an additional procedure.
%
% ## References
% [Yuen90]:
% > HK Yuen, John Princen, John Illingworth, and Josef Kittler.
% > "Comparative study of hough transform methods for circle finding".
% > Image and Vision Computing, 8(1):71-77, 1990.
%
% See also: cv.fitEllipse, cv.minEnclosingCircle, imfindcircles
%
