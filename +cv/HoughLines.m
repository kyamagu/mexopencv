%HOUGHLINES  Finds lines in a binary image using the standard Hough transform
%
%    lines = cv.HoughLines(image)
%    lines = cv.HoughLines(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ 8-bit, single-channel, grayscale input image.
%
% ## Output
% * __lines__ Output vector of lines. Each line is represented by a two-element
%         vector (rho,theta). rho is the distance from the coordinate origin
%         (0,0) (top-left corner of the image). theta is the line rotation angle
%         in radians (0 ~ vertical line, PI/2 ~ horizontal line).
%
% ## Options
% * __Rho__ Distance resolution of the accumulator in pixels. default 1.
% * __Theta__ Angle resolution of the accumulator in radians. default PI/180.
% * __Threshold__ Accumulator threshold parameter. Only those lines are
%         returned that get enough votes (>threshold). default 80.
% * __SRN__ For the multi-scale Hough transform, it is a divisor for the
%         distance resolution rho . The coarse accumulator distance resolution
%         is rho and the accurate accumulator resolution is rho/srn . If both
%         srn=0 and stn=0, the classical Hough transform is used. Otherwise,
%         both these parameters should be positive. default 0.
% * __STN__ For the multi-scale Hough transform, it is a divisor for the
%         distance resolution theta. default 0.
%
% The function implements the standard or standard multi-scale Hough transform
% algorithm for line detection. See
% http://homepages.inf.ed.ac.uk/rbf/HIPR2/hough.htm for a good explanation of
% Hough transform.
%
% See also cv.HoughLinesP
%
