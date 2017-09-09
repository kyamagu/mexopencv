%HOUGHPOINT2LINE  Calculates coordinates of line segment corresponded by point in Hough space
%
%     line = cv.HoughPoint2Line(houghPoint, srcImgInfo)
%     line = cv.HoughPoint2Line(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __houghPoint__ Point in Hough space `[x,y]`.
% * __srcImgInfo__ The source (input) image of Hough transform.
%
% ## Output
% * __line__ Coordinates of line segment corresponded by point in Hough space,
%   a 4-element integer vector `[vx,vy, ux,uy]`.
%
% ## Options
% * __AngleRange__ The part of Hough space where point is situated. See
%   cv.FastHoughTransform, default `ARO_315_135`.
% * __MakeSkew__ Specifies to do or not to do image skewing. See
%   cv.FastHoughTransform, default 'Deskew'.
% * __Rules__ Specifies strictness of line segment calculating. This specifies
%   the degree of rules validation. This can be used, for example, to choose
%   a proper way of input arguments validation. Default 'IgnoreBorders':
%   * __Strict__ Validate each rule in a proper way.
%   * __IgnoreBorders__ Skip validations of image borders.
%
% The function calculates coordinates of line segment corresponded by point in
% Hough space.
%
% ### Notes
% - If `Rules` parameter set to 'Strict' then returned line cut along the
%   border of source image.
% - If `Rules` parameter set to 'IgnoreBorders' then in case of point, which
%   belongs the incorrect part of Hough image, returned line will not
%   intersect source image.
%
% See also: cv.FastHoughTransform, cv.HoughLines, hough, houghlines, houghpeaks
%
