%GETGAUSSIANKERNEL  Returns Gaussian filter coefficients
%
%    kernel = cv.getGaussianKernel('OptionName', optionValue, ...)
%
%
% ## Output
% * __kernel__ Output kernel.
%
% ## Options
% * __KSize__ Aperture size. It should be odd (`ksize%2 ==1`) and positive.
%        default 5.
% * __Sigma__ Gaussian standard deviation. If it is non-positive, it is
%        computed from ksize as `sigma = 0.3 * ((ksize-1) * 0.5 - 1) + 0.8`.
%        default -1.
%
% The function computes and returns the ksize x 1 matrix of Gaussian filter
% coefficients
%
%     G_i = \alpha * \exp(-(i-(ksize-1)/2)^2/(2*\sigma)^2)
%
% where `i = 0, ..., ksize-1` and \alpha is the scale factor chosen so that
% `\sum_i G_i = 1`.
%
% Two of such generated kernels can be passed to cv.sepFilter2D. Those
% functions automatically recognize smoothing kernels (a symmetrical kernel
% with sum of weights equal to 1) and handle them accordingly. You may also
% use the higher-level cv.GaussianBlur
%
% See also cv.sepFilter2D cv.getDerivKernels cv.getStructuringElement
% cv.GaussianBlur
%
