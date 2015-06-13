%HOUGHCIRCLES  Finds circles in a grayscale image using the Hough transform
%
%    circles = cv.HoughCircles(image)
%    circles = cv.HoughCircles(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ 8-bit, single-channel, grayscale input image.
%
% ## Output
% * __circles__ Output vector of found circles. Each vector is encoded as a
%       3-element floating-point vector `[x, y, radius]`.
%
% ## Options
% * __Method__ Detection method, one of:
%       * __Standard__
%       * __Probabilistic__
%       * __MultiScale__
%       * __Gradient__
%       Currently, the only implemented method is 'Gradient' (default).
% * __DP__ Inverse ratio of the accumulator resolution to the image resolution.
%       For example, if `dp=1`, the accumulator has the same resolution as
%       the input image. If `dp=2`, the accumulator has half as big width
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
% **NOTE:** Usually the function detects the centers of circles well. However,
% it may fail to find correct radii. You can assist to the function by
% specifying the radius range (`minRadius` and `maxRadius`) if you know it.
% Or, you may ignore the returned radius, use only the center, and find the
% correct radius using an additional procedure.
%
% See also: cv.fitEllipse, cv.minEnclosingCircle
%
