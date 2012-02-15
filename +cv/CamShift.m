%CAMSHIFT  Finds an object center, size, and orientation
%
%    window = cv.CamShift(probImage, window, 'OptionName', optionValue, ...)
%
% ## Input
% * __probImage__ Back projection of the object histogram. See
%        cv.calcBackProject.
% * __window__ Initial window.
%
% ## Output
% * __window__ Output rectangle with rotation.
%
% ## Options
% * __Criteria__ Stop criteria for the underlying meanShift. Accepts a
%        struct with 'type', 'maxCount', and 'epsilon' fields.
%
% The function implements the CAMSHIFT object tracking algrorithm
% [Bradski98]. First, it finds an object center using cv.meanShift and then
% adjusts the window size and finds the optimal rotation. The function
% returns the rotated rectangle structure that includes the object
% position, size, and orientation. The next position of the search window
% can be obtained with RotatedRect::boundingRect.
%
% See also cv.meanShift cv.calcBackProject
%
