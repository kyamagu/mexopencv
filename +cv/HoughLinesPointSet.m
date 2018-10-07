%HOUGHLINESPOINTSET  Finds lines in a set of points using the standard Hough transform
%
%     lines = cv.HoughLinesPointSet(points)
%     lines = cv.HoughLinesPointSet(points, 'OptionName',optionValue, ...)
%
% ## Input
% * __points__ Input vector of points `{[x,y], ...}`, floating-point type.
%
% ## Output
% * __lines__ Output cell-array of found lines. Each line is encoded as a
%   3-element vector `[votes, rho, theta]`. The larger the value of `votes`,
%   the higher the reliability of the Hough line.
%
% ## Options
% * __LinesMax__ Max count of hough lines. default 200
% * __Threshold__ Accumulator threshold parameter. Only those lines are
%   returned that get enough votes (`> Threshold`). default 10
% * __RhoMin__ Minimum Distance value of the accumulator in pixels. default 0
% * __RhoMax__ Maximum Distance value of the accumulator in pixels.
%   default 100
% * __RhoStep__ Distance resolution of the accumulator in pixels. default 1
% * __ThetaMin__ Minimum angle value of the accumulator in radians. default 0
% * __ThetaMax__ Maximum angle value of the accumulator in radians.
%   default pi/2
% * __ThetaStep__ Angle resolution of the accumulator in radians.
%   default pi/180
%
% The function finds lines in a set of points using a modification of the
% Hough transform.
%
% See also: cv.HoughLines
%
