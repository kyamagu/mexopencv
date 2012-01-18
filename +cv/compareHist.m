%COMPAREHIST  Compares two histograms
%
%    d = compareHist(H1, H2)
%    d = compareHist(H1, H2, 'Method', method)
%
% Input:
%   H1: First compared histogram.
%   H2: Second compared histogram of the same size as H1.
% Output:
%   d: Output distance.
% Options:
%   'Method': Comparison method that could be one of the following:
%     'Correl': Correlation
%     'ChiSqr': Chi-Square
%     'Intersect': Intersection
%     'Bhattacharyya': Bhattacharyya distance
%
% The functions compareHist compare two dense or two sparse histograms
% using the specified method.
%
% While the function works well with 1-, 2-, 3-dimensional dense
% histograms, it may not be suitable for high-dimensional sparse
% histograms. In such histograms, because of aliasing and sampling
% problems, the coordinates of non-zero histogram bins can slightly shift.
% To compare such histograms or more general sparse configurations of
% weighted points, consider using the EMD() function.
%
% See also cv.calcHist cv.EMD
%
