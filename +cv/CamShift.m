%CAMSHIFT  Finds an object center, size, and orientation
%
%    box = cv.CamShift(probImage, window)
%    [box,window] = cv.CamShift(probImage, window)
%    [...] = cv.CamShift(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __probImage__ Back projection of the object histogram. See
%        cv.calcBackProject for details.
% * __window__ Initial search window `[x,y,w,h]`.
%
% ## Output
% * __box__ Output rectangle with rotation. A scalar structure of the form:
%       `struct('center',[x,y], 'size',[w,h], 'angle',a)`
% * __window__ Converged CAMSHIFT window `[x,y,w,h]`
%
% ## Options
% * __Criteria__ Stop criteria for the underlying cv.meanShift. Accepts a
%       struct with 'type', 'maxCount', and 'epsilon' fields.
%       Default `struct('type','Count+EPS', 'maxCount',100, 'epsilon',1.0)`
%
% The function implements the CAMSHIFT object tracking algrorithm
% [Bradski98]. First, it finds an object center using cv.meanShift and then
% adjusts the window size and finds the optimal rotation. The function
% returns the rotated rectangle structure that includes the object
% position, size, and orientation. The next position of the search window
% can be obtained with cv.RotatedRect.boundingRect.
%
% ## References
% [Bradski98]:
% > Gary R Bradski. Computer vision face tracking for use in a perceptual
% > user interface. 1998.
%
% See also: cv.meanShift. cv.calcBackProject, vision.HistogramBasedTracker
%
