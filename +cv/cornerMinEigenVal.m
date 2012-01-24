%CORNERMINEIGENVAL  Calculates the minimal eigenvalue of gradient matrices for corner detection
%
%   dst = cv.cornerMinEigenVal(src)
%   dst = cv.cornerMinEigenVal(src, 'KSize', [5,5], ...)
%
% Input:
%     src: Input single-channel 8-bit or floating-point image.
% Output:
%     dst: Image to store the results. It has the same size as src and the
%         single type.
% Options:
%     'BlockSize': Neighborhood size. default 5.
%     'ApertureSize': Aperture parameter for the Sobel() operator. default 3.
%     'BorderType': Border mode used to extrapolate pixels outside of the
%                   image. default 'Default'
%
% The function is similar to cv.cornerEigenValsAndVecs but it calculates and
% stores only the minimal eigenvalue of the covariance matrix of derivatives,
% that is,  in terms of the formulae in the cv.cornerEigenValsAndVecs
% description.
%
% See also cv.cornerEigenValsAndVecs
%