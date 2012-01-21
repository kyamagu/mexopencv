%APPROXPOLYDP  Approximates a polygonal curve(s) with the specified precision
%
%   approxCurve = cv.approxPolyDP(curve)
%   approxCurve = cv.approxPolyDP(curve, 'OptionName', optionValue, ...)
%
% Input:
%     curve: Input vector of a 2D point stored in numeric array or cell array.
% Output:
%     approxCurve: Result of the approximation. The type should match the type
%         of the input curve.
% Options:
%     'Epsilon': Parameter specifying the approximation accuracy. This is the
%         maximum distance between the original curve and its approximation.
%         default 2.0
%     'Closed': If true, the approximated curve is closed (its first and last
%         vertices are connected). Otherwise, it is not closed.
%
% The functions approxPolyDP approximate a curve or a polygon with another
% curve/polygon with less vertices so that the distance between them is less
% or equal to the specified precision. It uses the Douglas-Peucker algorithm
% http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm.
%