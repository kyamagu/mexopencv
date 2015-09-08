%APPROXPOLYDP  Approximates a polygonal curve(s) with the specified precision
%
%    approxCurve = cv.approxPolyDP(curve)
%    approxCurve = cv.approxPolyDP(curve, 'OptionName', optionValue, ...)
%
% ## Input
% * __curve__ Input vector of 2D points stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%       Supports integer (`int32`) and floating point (`single`) classes.
%
% ## Output
% * __approxCurve__ Result of the approximation. The type should match the
%       type of the input curve.
%
% ## Options
% * __Epsilon__ Parameter specifying the approximation accuracy. This is the
%       maximum distance between the original curve and its approximation.
%       default 2.0
% * __Closed__ If true, the approximated curve is closed (its first and last
%       vertices are connected). Otherwise, it is not closed. default true
%
% The functions cv.approxPolyDP approximate a curve or a polygon with another
% curve/polygon with less vertices so that the distance between them is less
% or equal to the specified precision. It uses the Douglas-Peucker algorithm
% http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm.
%
