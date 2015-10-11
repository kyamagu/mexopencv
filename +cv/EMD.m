%EMD  Computes the "minimal work" distance between two weighted point configurations
%
%    d = cv.EMD(signature1, signature2)
%    d = cv.EMD(signature1, signature2, 'OptionName', optionValue, ...)
%    [d, lowerBound, flow] = cv.EMD(...)
%
% ## Input
% * __signature1__ First signature, a `size1-by-(dims+1)` floating-point
%       matrix. Each row stores the point weight followed by the point
%       coordinates `[w,x1,x2,...,xn]`. The matrix is allowed to have a single
%       column (weights only) if the user-defined `Cost` matrix is used.
%       Weights can not be negative and must not all be zeros.
% * __signature2__ Second signature `size2-by-(dims+1)` of the same format as
%       `signature1`, though the number of rows may be different. The total
%       weights may be different. In this case an extra "dummy" point is added
%       to either `signature1` or `signature2`.
%
% ## Output
% * __d__ Output distance value.
% * __lowerBound__ Optional output lower boundary of a distance between the
%       two signatures. See 'LowerBound' in options.
% * __flow__ Optional resultant `size1-by-size2` flow matrix of type `single`.
%       `flow(i,j)` is a flow from i-th point of `signature1` to j-th point
%       of `signature2`.
%
% ## Options
% * __DistType__ Used metric,  default 'L2'. One of:
%       * __L1__ Manhattan distance: `d = |x1-x2| + |y1-y2|`
%       * __L2__ Euclidean distance: `d = sqrt((x1-x2)^2 + (y1-y2)^2)`
%       * __C__ Chebyshev distance: `d = max(|x1-x2|,|y1-y2|)`
%       * __User__ User-defined distance, means that a pre-calculated cost
%             matrix is used. Should be used when `Cost` is set.
% * __Cost__ User-defined `size1-by-size2` cost matrix. Also, if a cost matrix
%       is used, output lower boundary `lowerBound` cannot be calculated
%       because it needs a metric function. Not set by default
% * __LowerBound__ Optional input/output parameter: lower boundary of a
%       distance between the two signatures that is a distance between mass
%       centers. The lower boundary may not be calculated if the user-defined
%       cost matrix is used, the total weights of point configurations are not
%       equal, or if the signatures consist of weights only (the signature
%       matrices have a single column). If the calculated distance between
%       mass centers is greater or equal to `LowerBound` (it means that the
%       signatures are far enough), the function does not calculate EMD. In
%       any case `LowerBound` is set to the calculated distance between mass
%       centers on return. Thus, if you want to calculate both distance
%       between mass centers and EMD, `LowerBound` should be set to 0.
%       default 0.
%
% The function computes the earth mover distance and/or a lower boundary of
% the distance between the two weighted point configurations. One of the
% applications described in [RubnerSept98], [Rubner2000] is multi-dimensional
% histogram comparison for image retrieval. EMD is a transportation problem
% that is solved using some modification of a simplex algorithm, thus the
% complexity is exponential in the worst case, though, on average it is much
% faster. In the case of a real metric the lower boundary can be calculated
% even faster (using linear-time algorithm) and it can be used to determine
% roughly whether the two signatures are far enough so that they cannot relate
% to the same object.
%
% ## References
% [RubnerSept98]:
% > Yossi Rubner, Carlo Tomasi, and Leonidas J Guibas.
% > "The earth mover's distance as a metric for image retrieval". 1998.
%
% [Rubner2000]:
% > Yossi Rubner, Carlo Tomasi, and Leonidas J Guibas.
% > "The earth mover's distance as a metric for image retrieval".
% > International Journal of Computer Vision, 40(2):99-121, 2000.
%
% See also: cv.calcHist, cv.compareHist
%
