%KMEANS  Finds centers of clusters and groups input samples around the clusters
%
%   labels = cv.kmeans(samples, k)
%   [labels, centers, compactness] = cv.kmeans(...)
%   [...] = cv.kmeans(..., 'OptionName', optionValue, ...)
%
% Input:
%    samples: Floating-point matrix of input samples, one row per sample.
%    k: Number of clusters to split the set by.
% Output:
%    labels: Integer array that stores the cluster indices for every
%        sample.
%    centers: Output matrix of the cluster centers, one row per each
%        cluster center.
%    comactness: Measure of compactness. See below.
% Options:
%    'Criteria': The algorithm termination criteria, that is, the maximum
%        number of iterations and/or the desired accuracy. The accuracy is
%        specified as criteria.epsilon. As soon as each of the cluster
%        centers moves by less than criteria.epsilon on some iteration, the
%        algorithm stops.
%    'Attempts': The number of times the algorithm is executed using
%        different initial labelings. The algorithm returns the labels that
%        yield the best compactness (see the last function parameter).
%        default 10.
%    'Initialization': Method to initialize seeds. One of the followings:
%        'Random'  Select random initial centers in each attempt. (default)
%        'PP'      Use kmeans++ center initialization by Arthur and
%                  Vassilvitskii [Arthur2007].
%    'InitialLabels': Integer array that stores the initial cluster indices
%        for every sample.
%
% The function kmeans implements a k-means algorithm that finds the centers
% of clusterCount clusters and groups the input samples around the
% clusters. As an output,  contains a 0-based cluster index for the sample
% stored in the  row of the samples matrix.
%
% The function returns the compactness measure that is computed as
%
%    \sum_i || samples_i - centers_{labels_i} ||^2
%
% after every attempt. The best (minimum) value is chosen and the
% corresponding labels and the compactness value are returned by the
% function. Basically, you can use only the core of the function, set the
% number of attempts to 1, initialize labels each time using a custom
% algorithm, pass them with the ( flags = KMEANS_USE_INITIAL_LABELS ) flag,
% and then choose the best (most-compact) clustering.
%