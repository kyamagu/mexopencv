%CORNEREIGENVALSANDVECS  Calculates eigenvalues and eigenvectors of image blocks for corner detection
%
%    dst = cv.cornerEigenValsAndVecs(src)
%    dst = cv.cornerEigenValsAndVecs(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input single-channel 8-bit or floating-point image.
%
% ## Output
% * __dst__ Image to store the results. It has the same size as `src` and the
%       single type.
%
% ## Options
% * __BlockSize__ Neighborhood size. default 5.
% * __KSize__ Aperture parameter for the cv.Sobel operator. default 3.
% * __BorderType__ Pixel extrapolation method. default 'Default'
%
% For every pixel `p`, the function cv.cornerEigenValsAndVecs considers a
% `blockSize x blockSize` neigborhood `S(p)`. It calculates the covariation
% matrix of derivatives over the neighborhood as:
%
%    M = [
%        Sigma_over_Sp(dI/dx)^2      Sigma_over_Sp(dI/dx dI/dy)
%        Sigma_over_Sp(dI/dx dI/dy)  Sigma_over_Sp(dI/dy)^2
%    ]
%
% where the derivatives are computed using the Sobel operator.
%
% After that, it finds eigenvectors and eigenvalues of `M` and stores them in
% the destination image as where `(lambda_1, lambda_2, x_1, y_1, x_2, y_2)`
% where
%
% * `lambda_N` are the non-sorted eigenvalues of `M`
% * `x_N`, `y_N` are the eigenvectors corresponding to `lambda_N`
%
% The output of the function can be used for robust edge or corner detection.
%
% See also: cv.cornerMinEigenVal, cv.cornerHarris, cv.preCornerDetect
%
