%CLIPLINE  Clips the line against the image rectangle
%
%    [B,pt1,pt2] = cv.clipLine(imgSize, pt1, pt2)
%    [B,pt1,pt2] = cv.clipLine(imgRect, pt1, pt2)
%
% ## Input
% * __imgSize__ Image size. The image rectangle is Rect(0, 0, imgSize.width,
%        imgSize.height).
% * __imgRect__ Image rectangle.
% * __pt1__ First line point.
% * __pt2__ Second line point.
%
% ## Output
% * __B__ Logical value. See below.
% * __pt1__ First line point.
% * __pt2__ Second line point.
%
% The functions clipLine calculate a part of the line segment that is
% entirely within the specified rectangle. They return false if the line
% segment is completely outside the rectangle. Otherwise, they return true.
%
% See also cv.line
%
