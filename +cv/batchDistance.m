%BATCHDISTANCE  Naive nearest neighbor finder
%
%    [dst,nidx] = cv.batchDistance(src1, src2)
%    [...] = cv.batchDistance(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src1__ samples matrix of size N1-by-M, type either 'single' or 'uint8'
% * __src2__ samples matrix of size N2-by-M, type either 'single' or 'uint8'
%
% ## Output
% * __dst__ distance matrix (see description below).
% * __nidx__ zero-based indices of nearest neighbors (matrix of size N1-by-K).
%       Only computed if `K>0`, otherwise an empty matrix is returned.
%
% ## Options
% * __DType__ default -1
% * __NormType__ Distance metric used. Default 'L2'
% * __K__ Number of nearest neighbors in to find. If `K=0` (the default),
%       the full pairwaise distance matrix is computed (of size N1-by-N2),
%       otherwise only distances to the K-nearest neighbors is returned
%       (matrix of size N1-by-K).
% * __Mask__ Not set by default.
% * __Update__ default 0.
% * __CrossCheck__ default false.
%
% See http://en.wikipedia.org/wiki/Nearest_neighbor_search
%
% See also: pdist2, knnsearch
%
