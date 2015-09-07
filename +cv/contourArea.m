%CONTOURAREA  Calculates a contour area
%
%    a = cv.contourArea(curve)
%    a = cv.contourArea(curve, 'OptionName', optionValue, ...)
%
% ## Input
% * __curve__ Input vector of 2D points (contour vertices) stored in numeric
%       array (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors
%       (`{[x,y], ...}`).
%
% ## Output
% * __a__ Output area.
%
% ## Options
% * __Oriented__ Oriented area flag. If it is true, the function returns a
%         signed area value, depending on the contour orientation (clockwise or
%         counter-clockwise). Using this feature you can determine orientation
%         of a contour by taking the sign of an area. By default, the parameter
%         is false, which means that the absolute value is returned.
%
% The function computes a contour area. Similarly to cv.moments, the area is
% computed using the Green formula. Thus, the returned area and the number of
% non-zero pixels, if you draw the contour using cv.drawContours or cv.fillPoly,
% can be different. Also, the function will most certainly give a wrong results
% for contours with self-intersections.
%
% ## Example
%
%    contour = {[0 0], [10 0], [10 10], [5 4]};
%    area0 = cv.contourArea(contour);
%    approx = cv.approxPolyDP(contour, 'Epsilon',5, 'Closed',true);
%    area1 = cv.contourArea(approx);
%    fprintf('area0 = %.2f\narea1 = %.2f\napprox poly vertices = %d\n', ...
%        area0, area1, numel(approx));
%
% See also: cv.arcLength
%
