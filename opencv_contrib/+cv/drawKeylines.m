%DRAWKEYLINES  Draws keylines
%
%     outImg = cv.drawKeylines(im, keylines)
%     outImg = cv.drawKeylines(im, keylines, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ input image.
% * __keypoints__ keylines to be drawn.
%
% ## Output
% * __outImg__ output image to draw on.
%
% ## Options
% * __Color__ color of lines to be drawn (if set to defaul value, color is
%   chosen randomly). default [-1,-1,-1,-1].
% * __OutImage__ If set, keylines will be drawn on existing content of output
%   image, otherwise source image is used instead. Not set by default.
%   (i.e keylines are drawn on top of `im`).
%
% See also: cv.drawKeypoints, cv.drawLineMatches, cv.LSDDetector,
%  cv.BinaryDescriptor
%
