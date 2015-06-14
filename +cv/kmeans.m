%KMEANS  Finds centers of clusters and groups input samples around the clusters
%
%    labels = cv.kmeans(data, K)
%    [labels, centers, compactness] = cv.kmeans(...)
%    [...] = cv.kmeans(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __data__ Data for clustering. An array of D-dimensional points with
%       floating-point coordinates is needed. Examples of this matrix can be:
%       NxD numeric matrix (one row per sample), or Nx1xD/1xNxD array
%       (with dimensions across slices).
% * __K__ Number of clusters to split the set by.
%
% ## Output
% * __labels__ Integer array that stores the cluster indices for every
%        sample.
% * __centers__ Output matrix of the cluster centers, one row per each
%        cluster center.
% * __compactness__ Measure of compactness. See below.
%
% ## Options
% * __Criteria__ The algorithm termination criteria, that is, the maximum
%        number of iterations and/or the desired accuracy. The accuracy is
%        specified as `criteria.epsilon`. As soon as each of the cluster
%        centers moves by less than `criteria.epsilon` on some iteration, the
%        algorithm stops. default
%        `struct('type','Count+EPS', 'maxCount',100, 'epsilon',eps('float'))`
% * __Attempts__ The number of times the algorithm is executed using
%        different initial labelings. The algorithm returns the labels that
%        yield the best compactness (see the last function parameter).
%        default 10.
% * __Initialization__ Method to initialize seeds. One of the followings:
%     * 'Random'  Select random initial centers in each attempt. (default)
%     * 'PP'      Use kmeans++ center initialization by Arthur and
%                  Vassilvitskii [Arthur2007].
% * __InitialLabels__ Integer array that stores the initial cluster indices
%        for every sample. During the first (and possibly the only) attempt,
%        kmeans uses the user-supplied labels instead of computing them from
%        the initial centers. For the second and further attempts, it uses
%        the random or semi-random centers. Use one of the `Initialization`
%        methods to specify the exact method. Not set by default.
%
% The function cv.kmeans implements a k-means algorithm that finds the centers
% of `K` clusters and groups the input samples around the clusters. As an
% output, `labels(i)` contains a 0-based cluster index for the sample stored
% in the i-th row of the samples matrix.
%
% The function returns the compactness measure that is computed as:
%
%    \sum_i || samples_i - centers_{labels_i} ||^2
%
% after every attempt. The best (minimum) value is chosen and the
% corresponding labels and the compactness value are returned by the
% function. Basically, you can use only the core of the function, set the
% number of attempts to 1, initialize labels each time using a custom
% algorithm, pass them with the `InitialLabels` option, and then choose the
% best (most-compact) clustering.
%
% ## References
% [Arthur2007]:
% > D. Arthur, S. Vassilvitskii: "k-means++: the advantages of carefull seeding".
% > In Proceedings of the eighteenth annual ACM-SIAM symposium
% > on Discrete algorithms, 1027-1035, 2007.
%
% See also: kmeans
%
