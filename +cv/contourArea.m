%CONTOURAREA  Calculates a contour area
%
%    a = cv.contourArea(curve)
%    a = cv.contourArea(curve, 'OptionName', optionValue, ...)
%
% ## Input
% * __curve__ Input vector of a 2D point stored in numeric array or cell array.
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
% The function computes a contour area. Similarly to cv.moments , the area is
% computed using the Green formula. Thus, the returned area and the number of
% non-zero pixels, if you draw the contour using cv.drawContours or cv.fillPoly,
% can be different.
%
