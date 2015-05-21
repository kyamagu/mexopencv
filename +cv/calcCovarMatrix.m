%CALCCOVARMATRIX  Calculates the covariance matrix of a set of vectors.
%
%    [covar,mean] = cv.calcCovarMatrix(samples)
%    [...] = cv.calcCovarMatrix(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __samples__ Samples stored as rows/columns of a single matrix.
%
% ## Output
% * __covar__ Output covariance matrix of the type `CType` and square size.
% * __mean__ Output array as the average value of the input vectors.
%
% ## Options
% * __Mean__ Input array as the average value of the input vectors.
%       See 'UseAvg' below. It is not set by default
% * __Flags__ Operation flags. Default is equivalent to
%       {'Normal',true, 'Rows',true}
% * __Normal__ The covariance matrix will be a square matrix of the same
%       size as the total number of elements in each input vector. One
%       and only one of 'Scrambled' and 'Normal' must be specified.
%       default true
% * __Scrambled__ The covariance matrix will be `nsamples x nsamples`.
%       Such an unusual covariance matrix is used for fast cv.PCA of a
%       set of very large vectors (see, for example, the EigenFaces
%       technique for face recognition). Eigenvalues of this "scrambled"
%       matrix match the eigenvalues of the true covariance matrix. The
%       "true" eigenvectors can be easily calculated from the
%       eigenvectors of the "scrambled" covariance matrix. default false
% * __Rows__ If the flag is specified, all the input vectors are stored
%       as rows of the samples matrix. mean should be a single-row
%       vector in this case. default true
% * __Cols__ If the flag is specified, all the input vectors are stored
%       as columns of the samples matrix. mean should be a single-column
%       vector in this case. default false
% * __Scale__ If the flag is specified, the covariance matrix is scaled.
%       In the "normal" mode, scale is `1./nsamples`. In the "scrambled"
%       mode, scale is the reciprocal of the total number of elements in
%       each input vector. By default (if the flag is not specified),
%       the covariance matrix is not scaled (`scale=1`). default false
% * __UseAvg__ If the flag is specified, the function does not calculate
%       mean from the input vectors but, instead, uses the passed mean
%       vector. This is useful if mean has been pre-calculated or known
%       in advance, or if the covariance matrix is calculated by parts.
%       In this case, mean is not a mean vector of the input sub-set of
%       vectors but rather the mean vector of the whole set.
%       default false
% * __CType__ type of the matrix. default is 'double'
%
% The functions cv.calcCovarMatrix calculate the covariance matrix and,
% optionally, the mean vector of the set of input vectors.
%
% See also: cv.PCA, cov, mean
%
