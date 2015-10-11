%CORNERSUBPIX  Refines the corner locations
%
%    corners = cv.cornerSubPix(im, corners)
%    corners = cv.cornerSubPix(im, corners, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Input single-channel image.
% * __corners__ Initial coordinates of the input corners, stored in numeric
%       array (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors
%       (`{[x,y], ...}`). Supports single floating-point class.
%
% ## Output
% * __corners__ Output refined coordinates, of the same size and type as the
%       input `corners` (numeric or cell matching the input format).
%
% ## Options
% * __WinSize__ Half of the side length of the search window. For example, if
%       `WinSize=[5,5]`, then a `(5 * 2 + 1) x (5 * 2 + 1) = 11 x 11` search
%       window is used. default [3, 3].
% * __ZeroZone__ Half of the size of the dead region in the middle of the
%       search zone over which the summation in the formula below is not done.
%       It is used sometimes to avoid possible singularities of the
%       autocorrelation matrix. The value of `[-1,-1]` indicates that there
%       is no such a size. default [-1,-1].
% * __Criteria__ Criteria for termination of the iterative process of corner
%       refinement. That is, the process of corner position refinement stops
%       either after `criteria.maxCount` iterations or when the corner position
%       moves by less than `criteria.epsilon` on some iteration. Default to
%       `struct('type','Count+EPS', 'maxCount',50, 'epsilon',0.001)`.
%       Struct with the following fields is accepted:
%       * __type__ one of 'Count', 'EPS', or 'Count+EPS' to indicate which
%             criteria to use.
%       * __maxCount__ maximum number of iterations
%       * __epsilon__ minimum difference in corner position
%
% The function iterates to find the sub-pixel accurate location of corners or
% radial saddle points.
%
% Sub-pixel accurate corner locator is based on the observation that every
% vector from the center `q` to a point `p` located within a neighborhood of
% `q` is orthogonal to the image gradient at `p` subject to image and
% measurement noise. Consider the expression:
%
%    epsilon_i = DI_p_i' * (q - p_i)
%
% where `DI_p_i` is an image gradient at one of the points `p_i` in a
% neighborhood of `q`. The value of `q` is to be found so that `epsilon_i` is
% minimized. A system of equations may be set up with `epsilon_i` set to zero:
%
%    Sigma_i(DI_p_i * DI_p_i') - Sigma_i(DI_p_i * DI_p_i' * p_i)
%
% where the gradients are summed within a neighborhood ("search window") of
% `q`. Calling the first gradient term `G` and the second gradient term `b`
% gives:
%
%    q = inv(G) * b
%
% The algorithm sets the center of the neighborhood window at this new center
% `q` and then iterates until the center stays within a set threshold.
%
% See also: cv.find4QuadCornerSubpix
%
