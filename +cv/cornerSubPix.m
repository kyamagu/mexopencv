%CORNERSUBPIX  Refines the corner locations
%
%    corners = cv.cornerSubPix(im, corners)
%    corners = cv.cornerSubPix(im, corners, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Input image.
% * __corners__ Initial coordinates of the input corners.
%
% ## Output
% * __corners__ Output refined coordinates.
%
% ## Options
% * __WinSize__ Half of the side length of the search window. For example, if
%         winSize=Size(3,3), then a 3 * 2 + 1 x 3 * 2 + 1 = 7 x 7 search window
%         is used. default [3, 3].
% * __ZeroZone__ Half of the size of the dead region in the middle of the
%         search zone over which the summation in the formula below is not done.
%         It is used sometimes to avoid possible singularities of the
%         autocorrelation matrix. The value of (-1,-1) indicates that there is
%         no such a size. default [-1,-1].
% * __Criteria__ Criteria for termination of the iterative process of corner
%         refinement. That is, the process of corner position refinement stops
%         either after criteria.maxCount iterations or when the corner position
%         moves by less than criteria.epsilon on some iteration.
%
% The function iterates to find the sub-pixel accurate location of corners or
% radial saddle points.
%
