%MEANSHIFT  Finds an object on a back projection image
%
%    window = cv.meanShift(probImage, window)
%    [window,iter] = cv.meanShift(probImage, window)
%    [...] = cv.meanShift(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __probImage__ Back projection of the object histogram. See
%       cv.calcBackProject for details.
% * __window__ Initial search window `[x,y,w,h]`.
%
% ## Output
% * __window__ Converged CAMSHIFT window `[x,y,w,h]`.
% * __iter__ Number of iterations CAMSHIFT took to converge.
%
% ## Options
% * __Criteria__ Stop criteria for the iterative search algorithm. Accepts a
%       struct with 'type', 'maxCount', and 'epsilon' fields.
%       Default `struct('type','Count+EPS', 'maxCount',100, 'epsilon',1.0)`
%
% The function implements the iterative object search algorithm. It takes the
% input back projection of an object and the initial position. The mass center
% in window of the back projection image is computed and the search window
% center shifts to the mass center. The procedure is repeated until the
% specified number of iterations `Criteria.maxCount` is done or until the
% window center shifts by less than `Criteria.epsilon`. The algorithm is used
% inside cv.CamShift and, unlike cv.CamShift, the search window size or
% orientation do not change during the search. You can simply pass the output
% of cv.calcBackProject to this function. But better results can be obtained
% if you pre-filter the back projection and remove the noise. For example, you
% can do this by retrieving connected components with cv.findContours,
% throwing away contours with small area (cv.contourArea), and rendering the
% remaining contours with cv.drawContours.
%
% See also: cv.CamShift, cv.calcBackProject
%
