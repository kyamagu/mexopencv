%GROUPRECTANGLES_MEANSHIFT  Groups the object candidate rectangles using meanshift
%
%    [rects, weights] = cv.groupRectangles_meanshift(rects, weights, scales)
%    [...] = cv.groupRectangles_meanshift(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __rects__ Input cell array of rectangles, where each rectangle is
%       represented as a 4-element vector `{[x,y,w,h], ...}`, or a numeric
%       Nx4/Nx1x4/1xNx4 array.
% * __weights__ Input vector of associated weights.
% * __scales__ Input vector of corresponding rectangles scales.
%
% ## Output
% * __rects__ Output array of retained and grouped rectangles. Same format as
%       input `rects` (either Nx4 numeric array or cell array).
% * __weights__ Output updated weights.
%
% ## Options
% * __DetectThreshold__ detection threshold (weight) above which resulting
%       modes are kept. default 0.0
% * __WinDetSize__ window size `[w,h]`. default [64,128]
%
% See also: cv.groupRectangles, cv.SimilarRects
%
