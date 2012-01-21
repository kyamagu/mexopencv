%ARCLENGTH  Calculates a contour perimeter or a curve length
%
%   len = cv.arcLength(curve)
%   len = cv.arcLength(curve, 'OptionName', optionValue)
%
% Input:
%     curve: Input vector of a 2D point stored in numeric array or cell array.
% Output:
%     len: Output length.
% Options:
%     'Closed': Flag indicating whether the curve is closed or not. default
%         false.
%
% The function computes a curve length or a closed contour perimeter.
%