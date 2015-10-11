%CORNEREIGENVALSANDVECS  Calculates eigenvalues and eigenvectors of image blocks for corner detection
%
%    dst = cv.cornerEigenValsAndVecs(src)
%    dst = cv.cornerEigenValsAndVecs(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input single-channel 8-bit or floating-point image.
%
% ## Output
% * __dst__ Image to store the results. It has the same row/column size as
%       `src` and the `single` type (where `size(dst,3)==6`).
%       Eigenvalues and eigenvectors are stored along the channels, see below.
%
% ## Options
% * __BlockSize__ Neighborhood size (see details below). default 5.
% * __KSize__ Aperture parameter for the cv.Sobel operator. default 3.
% * __BorderType__ Pixel extrapolation method. default 'Default'
%
% For every pixel `p`, the function cv.cornerEigenValsAndVecs considers a
% `blockSize x blockSize` neigborhood `S(p)`. It calculates the covariation
% matrix of derivatives over the neighborhood as:
%
%    M = [
%        \sum_{S(p)}(dI/dx)^2        \sum_{S(p)}(dI/dx * dI/dy)
%        \sum_{S(p)}(dI/dx * dI/dy)  \sum_{S(p)}(dI/dy)^2
%    ]
%
% where the derivatives are computed using the Sobel operator.
%
% After that, it finds eigenvectors and eigenvalues of `M` and stores them in
% the destination image as `(lambda_1, lambda_2, x_1, y_1, x_2, y_2)` where:
%
% * `lambda_1`, `lambda_2` are the non-sorted eigenvalues of `M`
% * `x_1`, `y_1` are the eigenvectors corresponding to `lambda_1`
% * `x_2`, `y_2` are the eigenvectors corresponding to `lambda_2`
%
% The output of the function can be used for robust edge or corner detection.
%
% See also: cv.cornerMinEigenVal, cv.cornerHarris, cv.preCornerDetect
%
