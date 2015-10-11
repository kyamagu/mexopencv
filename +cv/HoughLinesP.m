%HOUGHLINESP  Finds line segments in a binary image using the probabilistic Hough transform
%
%    lines = cv.HoughLinesP(image)
%    lines = cv.HoughLinesP(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ 8-bit, single-channel binary source image.
%
% ## Output
% * __lines__ Output vector of lines. A cell-array of 4-element vectors
%       `{[x1,y1,x2,y2], ...}`, where `(x1,y1)` and `(x2,y2)` are the ending
%       points of each detected line segment.
%
% ## Options
% * __Rho__ Distance resolution of the accumulator in pixels. default 1.
% * __Theta__ Angle resolution of the accumulator in radians. default pi/180.
% * __Threshold__ Accumulator threshold parameter. Only those lines are
%       returned that get enough votes (`>Threshold`). default 80.
% * __MinLineLength__ Minimum line length. Line segments shorter than that are
%       rejected. default 0.
% * __MaxLineGap__ Maximum allowed gap between points on the same line to link
%       them. default 0.
%
% The function implements the probabilistic Hough transform algorithm for line
% detection, described in [Matas00].
%
% ## References
% [Matas00]:
% > Jiri Matas, Charles Galambos, and Josef Kittler.
% > Robust detection of lines using the progressive probabilistic hough transform.
% > Computer Vision and Image Understanding, 78(1):119-137, 2000.
%
% See also: cv.HoughLines, cv.LineSegmentDetector, houghlines
%
