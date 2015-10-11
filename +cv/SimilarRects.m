%SIMILARRECTS  Class for grouping object candidates, detected by Cascade Classifier, HOG etc.
%
%    b = cv.SimilarRects(r1, r2)
%    b = cv.SimilarRects(r1, r2, 'OptionName',optionValue, ...)
%
% ## Input
% * __r1__ First input rectangle, 4-element vector `[x,y,w,h]`.
% * __r2__ Second input rectangle.
%
% ## Output
% * __b__ logical output indicate whether rectangles are similar.
%
% ## Options
% * __EPS__ Relative difference between sides of the rectangles to consider
%       similar. default 0.2
%
% See also: cv.groupRectangles, cv.groupRectangles_meanshift
%
