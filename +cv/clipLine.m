%CLIPLINE  Clips the line against the image rectangle
%
%     [B,pt1,pt2] = cv.clipLine(imgSize, pt1, pt2)
%     [B,pt1,pt2] = cv.clipLine(imgRect, pt1, pt2)
%
% ## Input
% * __imgSize__ Image size `[w,h]`. The image rectangle is `[0, 0, w, h]`.
% * __imgRect__ Image rectangle `[x, y, w, h]`.
% * __pt1__ First line point `[x1,y1]`.
% * __pt2__ Second line point `[x2,y2]`.
%
% ## Output
% * __B__ Logical value. See below.
% * __pt1__ First line point.
% * __pt2__ Second line point.
%
% The function cv.clipLine calculates a part of the line segment that is
% entirely within the specified rectangle. It returns false if the line
% segment is completely outside the rectangle. Otherwise, it returns true.
%
% See also: cv.line
%
