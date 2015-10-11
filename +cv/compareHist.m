%COMPAREHIST  Compares two histograms
%
%    d = cv.compareHist(H1, H2)
%    d = cv.compareHist(H1, H2, 'Method', method)
%
% ## Input
% * __H1__ First compared histogram. Both dense or sparse arrays are supported
%       (single-precision floating-point).
% * __H2__ Second compared histogram of the same size and type as `H1`.
%
% ## Output
% * __d__ Output distance `d(H1,H2)`.
%
% ## Options
% * __Method__ Comparison method, default 'Correlation'. See below.
%
% The function compares two dense or two sparse histograms using the specified
% method.
%
% While the function works well with 1-, 2-, 3-dimensional dense histograms,
% it may not be suitable for high-dimensional sparse histograms. In such
% histograms, because of aliasing and sampling problems, the coordinates of
% non-zero histogram bins can slightly shift. To compare such histograms or
% more general sparse configurations of weighted points, consider using the
% cv.EMD function.
%
% Histogram comparison methods:
%
% * __Correlation__ Correlation.
%
%        d(H1,H2) = (sum_{I}((H1(I) - H1_hat(I))*(H2(I) - H2_hat(I)))) /
%                   (sum_{I}(H1(I) - H1_hat(I))^2 * sum_{I}(H2(I) - H2_hat(I))^2)
%
%       where `Hk_hat = 1/N * sum_{J} Hk(J)` and `N` is a total number of
%       histogram bins.
% * __ChiSquare__ Chi-Square.
%
%        d(H1,H2) = sum_{I} ((H1(I) - H2(I))^2 / H1(I))
%
% * __Intersection__ Intersection.
%
%        d(H1,H2) = sum_{I} min(H1(I), H2(I))
%
% * __Bhattacharyya__ Bhattacharyya distance (In fact, OpenCV computes
%       Hellinger distance, which is related to Bhattacharyya coefficient).
%
%        d(H1,H2) = sqrt(1 - (1/sqrt(H1_hat(I)*H2_hat(I)*N^2)) * sum_{I}(sqrt(H1(I)*H2(I))))
%
% * __Hellinger__ Synonym for 'Bhattacharyya'.
% * __AltChiSquare__ Alternative Chi-Square.
%
%        d(H1,H2) = 2 * sum_{I} ((H1(I) - H2(I))^2 / (H1(I) + H2(I)))
%
%       This alternative formula is regularly used for texture comparison.
%       See e.g. [Puzicha1997]
% * __KullbackLeibler__ Kullback-Leibler divergence.
%
%        d(H1,H2) = sum_{I} (H1(I) * log(H1(I)/H2(I)))
%
% ## References
% [Puzicha1997]:
% > Jan Puzicha, Thomas Hofmann, and Joachim M Buhmann. "Non-parametric
% > similarity measures for unsupervised texture segmentation and image
% > retrieval". In Computer Vision and Pattern Recognition, 1997.
% > Proceedings., 1997 IEEE Computer Society Conference on, pages 267-272.
%
% See also: cv.calcHist, cv.EMD
%
