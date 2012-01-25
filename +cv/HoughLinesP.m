%HOUGHLINESP  Finds line segments in a binary image using the probabilistic Hough transform
%
%   lines = cv.HoughLines(image)
%
% Input:
%     image: 8-bit, single-channel, grayscale input image.
% Output:
%     lines: Output vector of lines. Each line is represented by a 4-element
%         vector (x1,y1,x2,y2), where (x1,y1) and (x2,y2) are the ending points
%         of each detected line segment
% Options:
%     'Rho': Distance resolution of the accumulator in pixels. default 1.
%     'Theta': Angle resolution of the accumulator in radians. default PI/180.
%     'Threshold': Accumulator threshold parameter. Only those lines are
%         returned that get enough votes (>threshold). default 80.
%     'MinLineLength': Minimum line length. Line segments shorter than that are
%         rejected. default 0.
%     'MaxLineGap': Maximum allowed gap between points on the same line to link
%         them. default 0.
%
% The function implements the probabilistic Hough transform algorithm for line
% detection, described in [Matas00].
%
% See also cv.HoughLines
%