%GROUPRECTANGLES  Groups the object candidate rectangles
%
%    rects = cv.groupRectangles(rects)
%    [rects,weights,levelWeights] = cv.groupRectangles(...)
%    [...] = cv.groupRectangles(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __rects__ Input cell array of rectangles, where each rectangle is
%       represented as a 4-element vector `{[x,y,w,h], ...}`, or a numeric
%       Nx4/Nx1x4/1xNx4 array.
%
% ## Output
% * __rects__ Output array of retained and grouped rectangles. Same format as
%       input `rects` (either Nx4 numeric array or cell array). Grouped
%       rectangles are the average of all rectangles in that cluster.
% * __weights__ optional output of filled/updated weights, with same length as
%       output `rects`. See `Weights` option. Corresponding grouped weights
%       are the maximum weights of all rectangles in that cluster.
% * __levelWeights__ optional output of filled/updated level weights, with
%       same length as output `rects`. See `LevelWeights` option.
%
% ## Options
% * __Thresh__ Minimum possible number of rectangles in a group minus 1. The
%       threshold is used in a group of rectangles to decide whether to retain
%       it or not. If less than or equal to zero, no grouping is performed.
%       default 1 (i.e only groups with two or more rectangles are kept).
% * __EPS__ Relative difference between sides of the rectangles to merge
%       them into a group. default 0.2
% * __Weights__ optional vector of associated weights of same length as input
%       `rects`. Not set by default
% * __LevelWeights__ optional vector of doubles of same length as input
%       `rects`. Not set by default
%
% The function is a wrapper for the generic partition function. It clusters
% all the input rectangles using the rectangle equivalence criteria that
% combines rectangles with similar sizes and similar locations. The similarity
% is defined by `EPS`. When `EPS=0`, no clustering is done at all. If
% `EPS -> +inf`, all the rectangles are put in one cluster. Then, the small
% clusters containing less than or equal to `Thresh` rectangles are rejected.
% In each other cluster, the average rectangle is computed and put into the
% output rectangle list. The function also filters out small rectangles inside
% larger ones that have more hits.
%
% The function is useful for non-max suppression of object detections.
%
% See also: cv.CascadeClassifier, cv.HOGDescriptor, cv.SimilarRects,
%   cv.groupRectangles_meanshift, selectStrongestBbox
%
