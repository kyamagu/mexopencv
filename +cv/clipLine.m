%CLIPLINE  Clips the line against the image rectangle
%
%   [B,pt1,pt2] = cv.clipLine(imgSize, pt1, pt2)
%   [B,pt1,pt2] = cv.clipLine(imgRect, pt1, pt2)
%
% Input:
%    imgSize: Image size. The image rectangle is Rect(0, 0, imgSize.width,
%        imgSize.height).
%    imgRect: Image rectangle.
%    pt1: First line point.
%    pt2: Second line point.
% Output:
%    B: Logical value. See below.
%    pt1: First line point.
%    pt2: Second line point.
%
% The functions clipLine calculate a part of the line segment that is
% entirely within the specified rectangle. They return false if the line
% segment is completely outside the rectangle. Otherwise, they return true.
%
% See also cv.line
%