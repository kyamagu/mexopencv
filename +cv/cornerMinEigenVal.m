%CORNERMINEIGENVAL  Calculates the minimal eigenvalue of gradient matrices for corner detection
%
%    dst = cv.cornerMinEigenVal(src)
%    dst = cv.cornerMinEigenVal(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input single-channel 8-bit or floating-point image.
%
% ## Output
% * __dst__ Image to store the minimal eigenvalues. It has the same size as
%       `src` and the `single` type (single-channel).
%
% ## Options
% * __BlockSize__ Neighborhood size (see the details on
%       cv.cornerEigenValsAndVecs). default 5.
% * __KSize__ Aperture parameter for the cv.Sobel operator. default 3.
% * __BorderType__ Pixel extrapolation method. default 'Default'
%
% The function is similar to cv.cornerEigenValsAndVecs but it calculates and
% stores only the minimal eigenvalue of the covariance matrix of derivatives,
% that is, `min(lambda_1,lambda_2)` in terms of the formulae in the
% cv.cornerEigenValsAndVecs description.
%
% See also: cv.cornerEigenValsAndVecs, detectMinEigenFeatures
%
