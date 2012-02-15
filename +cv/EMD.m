%EMD  Computes the 'minimal' work distance between two weighted point configurations
%
%    d = cv.EMD(signature1, signature2)
%    d = cv.EMD(signature1, signature2, 'OptionName', optionValue, ...)
%    [d, lowerBound, flow] = cv.EMD(...)
%
% ## Input
% * __signature1__ First signature, a size1 x dims + 1 floating-point matrix.
%       Each row stores the point weight followed by the point coordinates.
%       The matrix is allowed to have a single column (weights only) if the
%       user-defined cost matrix is used.
% * __signature2__ Second signature of the same format as signature1, though
%       the number of rows may be different. The total weights may be
%       different. In this case an extra ?dummy? point is added to either
%       signature1 or signature2.
%
% ## Output
% * __d__ Output distance value.
% * __lowerBound__ lower boundary of a distance between the two signatures.
%       See 'LowerBound' in options.
% * __flow__ Resultant size1 x size2 flow matrix: flow(i,j) is a flow from
%       i-th point of signature1 to j-th point of signature2
%
% ## Options
% * __DistType__ Used metric.'L1', 'L2', and 'C' stand for one of the
%       standard metrics. 'User' means that a pre-calculated cost matrix
%       cost is used. default 'L2'.
% * __Cost__ User-defined  size1 x size2 cost matrix. Also, if a cost matrix
%       is used, lower boundary lowerBound cannot be calculated because it
%       needs a metric function.
% * __LowerBound__ Optional input/output parameter: lower boundary of a
%       distance between the two signatures that is a distance between
%       mass centers. The lower boundary may not be calculated if the
%       user-defined cost matrix is used, the total weights of point
%       configurations are not equal, or if the signatures consist of
%       weights only (the signature matrices have a single column). If the
%       calculated distance between mass centers is greater or equal to
%       lowerBound (it means that the signatures are far enough), the
%       function does not calculate EMD. In any case lowerBound is set to
%       the calculated distance between mass centers on return. Thus, if
%       you want to calculate both distance between mass centers and EMD,
%       lowerBound should be set to 0. default 0.
%
% The function computes the earth mover distance and/or a lower boundary
% of the distance between the two weighted point configurations. One of
% the applications described in [RubnerSept98] is multi-dimensional
% histogram comparison for image retrieval. EMD is a transportation
% problem that is solved using some modification of a simplex algorithm,
% thus the complexity is exponential in the worst case, though, on average
% it is much faster. In the case of a real metric the lower boundary can
% be calculated even faster (using linear-time algorithm) and it can be
% used to determine roughly whether the two signatures are far enough so
% that they cannot relate to the same object.
%
% See also cv.calcHist cv.compareHist
%
