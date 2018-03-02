%COVARIANCEESTIMATION  Computes the estimated covariance matrix of an image using the sliding window formulation
%
%     dst = cv.covarianceEstimation(src, windowSize)
%
% ## Input
% * __src__ The source image. Input image must be of a complex type and
%   floating-point type. Input should be arranged as a 2-channels matrix
%   `size(src,3)==2` (corresponding to real and imaginary parts).
% * __windowSize__ The number of rows and cols in the window
%   `[windowRows,windowCols]`.
%
% ## Output
% * __dst__ The destination estimated covariance matrix. Output matrix will be
%   of size `[windowRows*windowCols, windowRows*windowCols, 2]` (channels
%   correspond to real and imaginary parts).
%
% The window size parameters control the accuracy of the estimation. The
% sliding window moves over the entire image from the top-left corner to the
% bottom right corner. Each location of the window represents a sample. If the
% window is the size of the image, then this gives the exact covariance
% matrix. For all other cases, the sizes of the window will impact the number
% of samples and the number of elements in the estimated covariance matrix.
%
% Algorithmic details of this algorithm can be found at [1].
% A previous and less efficient version of the algorithm can be found [2].
%
% ## References
% [1]:
% > O. Green, Y. Birk, "A Computationally Efficient Algorithm for the 2D
% > Covariance Method", ACM/IEEE International Conference on High Performance
% > Computing, Networking, Storage and Analysis, Denver, Colorado, 2013
%
% [2]:
% > O. Green, L. David, A. Galperin, Y. Birk, "Efficient parallel computation
% > of the estimated covariance matrix", arXiv, 2013
%
% See also: cv.calcCovarMatrix
%
