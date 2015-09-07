%BLUR  Smoothes an image using the normalized box filter
%
%    dst = cv.blur(src)
%    dst = cv.blur(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image; it can have any number of channels, which are
%       processed independently, but the depth should be `uint8`, `uint16`,
%       `int16`, `single`, or `double`.
%
% ## Output
% * __dst__ output image of the same size and type as `src`.
%
% ## Options
% * __KSize__ blurring kernel size. default [5,5]
% * __Anchor__ Anchor point `[x,y]`. The default value `[-1,-1]` means that
%       the anchor is at the kernel center.
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%       image. See cv.copyMakeBorder. default 'Default'
%
% The function smoothes an image using the kernel:
%
%    K = ones(KSize) / prod(KSize)
%
% See also: cv.boxFilter, cv.bilateralFilter, cv.GaussianBlur, cv.medianBlur
%
