%CORNERSUBPIX  Refines the corner locations
%
%    corners = cv.cornerSubPix(im, corners)
%    corners = cv.cornerSubPix(im, corners, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Input single-channel image.
% * __corners__ Initial coordinates of the input corners. Cell array of
%         2-element arrays `{[x,y], ...}`
%
% ## Output
% * __corners__ Output refined coordinates. Cell array of the same size as
%         the input `corners`.
%
% ## Options
% * __WinSize__ Half of the side length of the search window. For example, if
%         `WinSize=[3,3]`, then a `(3 * 2 + 1) x (3 * 2 + 1) = 7 x 7` search
%         window is used. default [3, 3].
% * __ZeroZone__ Half of the size of the dead region in the middle of the
%         search zone over which the summation in the formula below is not done.
%         It is used sometimes to avoid possible singularities of the
%         autocorrelation matrix. The value of [-1,-1] indicates that there is
%         no such a size. default [-1,-1].
% * __Criteria__ Criteria for termination of the iterative process of corner
%         refinement. That is, the process of corner position refinement stops
%         either after `criteria.maxCount` iterations or when the corner position
%         moves by less than `criteria.epsilon` on some iteration.
%         Struct with `{'type','maxCount','epsilon'}` fields is accepted. The
%         type field should have one of 'Count', 'EPS', or 'Count+EPS' to
%         indicate which criteria to use. Default to
%         `struct('type','Count+EPS', 'maxCount',50, 'epsilon',0.001)`.
%
% The function iterates to find the sub-pixel accurate location of corners or
% radial saddle points.
%
