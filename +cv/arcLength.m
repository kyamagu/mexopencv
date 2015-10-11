%ARCLENGTH  Calculates a contour perimeter or a curve length
%
%    len = cv.arcLength(curve)
%    len = cv.arcLength(curve, 'OptionName', optionValue)
%
% ## Input
% * __curve__ Input vector of 2D points stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __len__ Output length.
%
% ## Options
% * __Closed__ Flag indicating whether the curve is closed or not.
%       default false.
%
% The function computes a curve length or a closed contour perimeter.
%
% See also: cv.contourArea
%
