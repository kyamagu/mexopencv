%FILTER2D  Convolves an image with the kernel
%
%    dst = cv.filter2D(src, kernel)
%    dst = cv.filter2D(src, kernel, 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image.
% * __kernel__ Convolution kernel (or rather a correlation kernel), a
%       single-channel floating point matrix. If you want to apply different kernels to
%       different channels, split the image into separate color planes and
%       process them individually.
%
% ## Output
% * __result__ output image of the same size and the same number of channels
%       as `src`.
%
% ## Options
% * __Anchor__ Anchor of the kernel that indicates the relative position of a
%       filtered point within the kernel. The anchor should lie within the
%       kernel. The special default value (-1,-1) means that the anchor is at
%       the kernel center.
% * __BorderType__ Pixel extrapolation method, see cv.copyMakeBorder.
%       Default 'Default'
%
% The function applies an arbitrary linear filter to an image. When the
% aperture is partially outside the image, the function interpolates outlier
% pixel values according to the specified border mode.
%
% The function does actually compute correlation, not the convolution:
%
%    dst(x,y) = \sum_{0 <= xp <= size(kernel,2), 0 <= yp <= size(kernel,1)}
%               kernel(xp,yp) * src(x + xp - anchor(1), y + yp - anchor(2))
%
% That is, the kernel is not mirrored around the anchor point. If you need a
% real convolution, flip the kernel using cv.flip and set the new anchor to
% `(size(kernel,2) - anchor(1) - 1, size(kernel,1) - anchor(2) - 1)`.
%
% The function uses the DFT-based algorithm in case of sufficiently large
% kernels (~`11x11` or larger) and the direct algorithm for small kernels.
%
% See also: cv.sepFilter2D, cv.dft, cv.matchTemplate
%
