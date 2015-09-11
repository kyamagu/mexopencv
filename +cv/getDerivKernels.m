%GETDERIVKERNELS  Returns filter coefficients for computing spatial image derivatives
%
%    [kx, ky] = cv.getDerivKernels('OptionName', optionValue, ...)
%
% ## Output
% * __kx__ Output matrix of row filter coefficients. It has the type `KType`.
% * __ky__ Output matrix of column filter coefficients. It has the type
%       `KType`.
%
% ## Options
% * __Dx__ Derivative order in respect of x. default 1
% * __Dy__ Derivative order in respect of y. default 1
% * __KSize__ Aperture size. It can be 'Scharr', 1, 3, 5, or 7. default 3.
% * __Normalize__ Flag indicating whether to normalize (scale down) the filter
%       coefficients or not. Theoretically, the coefficients should have the
%       `denominator = 2^(KSize*2-Dx-Dy-2)`. If you are going to fitler
%       floating-point images, you are likely to use the normalized kernels.
%       But if you compute derivatives of an 8-bit image, store the results in
%       a 16-bit image, and wish to preserve all the fractional bits, you may
%       want to set `Normalize=false`. default false
% * __KType__ Type of filter coefficients. It can be `single` or `double`.
%       default `single`
%
% The function computes and returns the filter coefficients for spatial image
% derivatives. When `KSize='Scharr'`, the Scharr 3x3 kernels are generated
%(see cv.Scharr). Otherwise, Sobel kernels are generated (see cv.Sobel). The
% filters are normally passed to cv.sepFilter2D.
%
% See also: cv.sepFilter2D, cv.getDerivKernels, cv.getStructuringElement
%
