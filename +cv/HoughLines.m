%HOUGHLINES  Finds lines in a binary image using the standard Hough transform
%
%    lines = cv.HoughLines(image)
%    lines = cv.HoughLines(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ 8-bit, single-channel binary source image.
%
% ## Output
% * __lines__ Output vector of lines. A cell-array of 2-element vectors
%       `{[rho,theta], ...}`. `rho` is the distance from the coordinate origin
%       `(0,0)` (top-left corner of the image). `theta` is the line rotation
%       angle in radians (0 ~ vertical line, pi/2 ~ horizontal line).
%
% ## Options
% * __Rho__ Distance resolution of the accumulator in pixels. default 1.
% * __Theta__ Angle resolution of the accumulator in radians. default pi/180.
% * __Threshold__ Accumulator threshold parameter. Only those lines are
%       returned that get enough votes (`>Threshold`). default 80.
% * __SRN__ For the multi-scale Hough transform, it is a divisor for the
%       distance resolution `Rho`. The coarse accumulator distance resolution
%       is `Rho` and the accurate accumulator resolution is `Rho/SRN`. If both
%       `SRN=0` and `STN=0`, the classical Hough transform is used. Otherwise,
%       both these parameters should be positive. default 0.
% * __STN__ For the multi-scale Hough transform, it is a divisor for the
%       distance resolution `Theta`. default 0.
% * __MinTheta__ For standard and multi-scale Hough transform, minimum angle
%       to check for lines. Must fall between 0 and `MaxTheta`. default 0
% * __MaxTheta__ For standard and multi-scale Hough transform, maximum angle
%       to check for lines. Must fall between `MinTheta` and pi. default pi
%
% The function implements the standard or standard multi-scale Hough transform
% algorithm for line detection. See
% http://homepages.inf.ed.ac.uk/rbf/HIPR2/hough.htm
% for a good explanation of Hough transform.
%
% See also: cv.HoughLinesP, hough, houghpeaks, houghlines
%
