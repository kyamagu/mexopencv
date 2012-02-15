%CORNEREIGENVALSANDVECS  Calculates eigenvalues and eigenvectors of image blocks for corner detection
%
%    dst = cv.cornerEigenValsAndVecs(src)
%    dst = cv.cornerEigenValsAndVecs(src, 'KSize', [5,5], ...)
%
% ## Input
% * __src__ Input single-channel 8-bit or floating-point image.
%
% ## Output
% * __dst__ Image to store the results. It has the same size as src and the
%         single type.
%
% ## Options
% * __BlockSize__ Neighborhood size. default 5.
% * __ApertureSize__ Aperture parameter for the Sobel() operator. default 3.
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%                   image. default 'Default'
%
% For every pixel p, the function cornerEigenValsAndVecs considers a blockSize x
% blockSize neigborhood S(p). It calculates the covariation matrix of
% derivatives over the neighborhood.
%
% After that, it finds eigenvectors and eigenvalues of M and stores them in the
% destination image as where (\lambda\_1, \lambda\_2, x\_1, y\_1, x\_2, y\_2) where
%
%     \lambda_N are the non-sorted eigenvalues of M
%     x_N are the eigenvectors corresponding to \lambda_N
%
% The output of the function can be used for robust edge or corner detection.
%
