%GROUPRECTANGLES  Groups the object candidate rectangles
%
%    rects = cv.groupRectangles(rects, thresh)
%    [...] = cv.groupRectangles(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __rects__ Cell array of rectangles, where each rectangle is represented
%     as a 4-element vector [x,y,w,h].
% * __thresh__ Minimum possible number of rectangles minus 1. The threshold
%     is used in a group of rectangles to retain it.
%
% ## Output
% * __rects__ Cell array of grouped rectangles. the same format to the
%     input.
%
% ## Options
% * __EPS__ Relative difference between sides of the rectangles to merge
%     them into a group.
%
% The function clusters all the input rectangles using the rectangle
% equivalence criteria that combines rectangles with similar sizes and
% similar locations. The similarity is defined by eps. When `eps=0`, no
% clustering is done at all. If `eps->+inf`, all the rectangles are put in
% one cluster. Then, the small clusters containing less than or equal to
% `thresh` rectangles are rejected. In each other cluster, the
% average rectangle is computed and put into the output rectangle list.
%
% The function is useful for non-max suppression of object detections.
%
% See also cv.CascadeClassifier
%
