%COMPAREHIST  Compares two histograms
%
%    d = cv.compareHist(H1, H2)
%    d = cv.compareHist(H1, H2, 'Method', method)
%
% ## Input
% * __H1__ First compared histogram.
% * __H2__ Second compared histogram of the same size as H1.
%
% ## Output
% * __d__ Output distance.
%
% ## Options
% * __Method__ Comparison method that could be one of the following:
%     * __'Correl'__ Correlation
%     * __'ChiSqr'__ Chi-Square
%     * __'Intersect'__ Intersection
%     * __'Bhattacharyya'__ Bhattacharyya distance
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
