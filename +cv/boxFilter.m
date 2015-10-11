%BOXFILTER  Blurs an image using the box filter
%
%    dst = cv.boxFilter(src)
%    dst = cv.boxFilter(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image.
%
% ## Output
% * __dst__ output image of the same size and type as `src`.
%
% ## Options
% * __DDepth__ the output image depth (-1 to use `class(src)`). Default -1.
%       See cv.filter2D for details.
% * __KSize__ blurring kernel size. Default [5,5]
% * __Anchor__ anchor point `[x,y]`; default value [-1,-1] means that the
%       anchor is at the kernel center.
% * __Normalize__ flag, specifying whether the kernel is normalized by its
%       area or not. default true
% * __BorderType__ border mode used to extrapolate pixels outside of the
%       image. See cv.copyMakeBorder. Default 'Default'
%
% The function smoothes an image using the kernel:
%
%    K = alpha * ones(KSize)
%
% where:
%
%            | 1/prod(KSize)  when Normalize=true
%    alpha = |
%            | 1              otherwise
%
% Unnormalized box filter is useful for computing various integral
% characteristics over each pixel neighborhood, such as covariance matrices
% of image derivatives (used in dense optical flow algorithms, and so on). If
% you need to compute pixel sums over variable-size windows, use cv.integral.
%
% See also: cv.blur, cv.bilateralFilter, cv.GaussianBlur, cv.medianBlur,
%  cv.integral, cv.sqrBoxFilter
%
