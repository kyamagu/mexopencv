%CORNERHARRIS  Harris edge detector
%
%   dst = cv.cornerHarris(src)
%   dst = cv.cornerHarris(src, 'KSize', [5,5], ...)
%
% Input:
%     src: Input single-channel 8-bit or floating-point image.
% Output:
%     dst: Image to store the results. It has the same size as src and the
%         single type.
% Options:
%     'BlockSize': Neighborhood size. default 5.
%     'ApertureSize': Aperture parameter for the Sobel() operator. default 3.
%     'K': Harris detector free parameter.
%     'BorderType': Border mode used to extrapolate pixels outside of the
%                   image. default 'Default'
%
% The function runs the Harris edge detector on the image. Similarly to
% cv.cornerMinEigenVal and cv.cornerEigenValsAndVecs, for each pixel (x,y) it
% calculates a 2 x 2 gradient covariance matrix M(x,y) over a BlockSize x 
% BlockSize neighborhood. Then, it computes the following characteristic:
%
%     dst(x,y) = det(M(x,y)) - k x (tr(M(x,y)))^2
%
% Corners in the image can be found as the local maxima of this response map.
%