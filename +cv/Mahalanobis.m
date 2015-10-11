%MAHALANOBIS  Calculates the Mahalanobis distance between two vectors
%
%    d = cv.Mahalanobis(v1, v2, icovar)
%
% ## Input
% * __v1__ first 1D input vector.
% * __v2__ second 1D input vector.
% * __icovar__ inverse covariance matrix.
%
% ## Output
% * __d__ Mahalanobis distance.
%
% The function Mahalanobis calculates and returns the weighted distance
% between two vectors:
%
%    d(v1,v2) = sqrt( sum_{i,j} [icovar(i,j) * (v1(I) - v2(I)) * (v1(j) - v2(j))] )
%
% The covariance matrix may be calculated using the cv.calcCovarMatrix
% function and then inverted using the cv.invert function (preferably using
% the 'SVD' method, as the most accurate).
%
% See also: cv.calcCovarMatrix, cv.invert, cov
%
