%GETDERIVKERNELS  Returns Gaussian filter coefficients
%
%    [kx, ky] = cv.getDerivKernels('OptionName', optionValue, ...)
%
%
% ## Output
% * __kx__ Output kernel for x axis.
% * __ky__ Output kernel for y axis.
%
% ## Options
% * __Dx__ Derivative order in respect of x.
% * __Dy__ Derivative order in respect of y.
% * __KSize__ Aperture size. It can be 'Scharr', 1, 3, 5, or 7. default 3.
% * __Normalize__ Flag indicating whether to normalize (scale down) the
%        filter coefficients or not. Theoretically, the coefficients should
%        have the denominator = 2^(ksize*2-dx-dx-dy-2). If you are going to
%        filter floating-point images, you are likely to use the normalized
%        kernels. But if you compute derivatives of an 8-bit image, store
%        the results in a 16-bit image, and wish to preserve all the
%        fractional bits, you may want to set normalize=false.
%
% The function computes and returns the filter coefficients for spatial
% image derivatives. When ksize='Scharr', the Scharr 3 x 3 kernels are
% generated (see cv.Scharr). Otherwise, Sobel kernels are generated (see
% cv.Sobel). The filters are normally passed to cv.sepFilter2D.
%
% See also cv.sepFilter2D cv.getDerivKernels cv.getStructuringElement
%
