%FILTER2D  Convolves an image with the kernel
%
%    dst = cv.filter2D(src, kernel)
%    dst = cv.filter2D(src, kernel, 'Anchor', [0,1], ...)
%
% ## Input
% * __img__ Source image.
% * __kernel__ Convolution kernel (or rather a correlation kernel), a
%         single-channel floating point matrix. If you want to apply different kernels to
%         different channels, split the image into separate color planes and
%         process them individually.
%
% ## Output
% * __result__ Destination image of the same size and the same number of
%         channels as src.
%
% ## Options
% * __Anchor__ Anchor of the kernel that indicates the relative position of
%         a filtered point within the kernel. The anchor should lie within
%         the kernel. The special default value (-1,-1) means that the anchor
%         is at the kernel center.
% * __BorderType__ Pixel extrapolation method. Default 'Default'
%
% The function applies an arbitrary linear filter to an image. In-place
% operation is supported. When the aperture is partially outside the image, the
% function interpolates outlier pixel values according to the specified border
% mode.
%
% The function does actually compute correlation, not the convolution. That is,
% the kernel is not mirrored around the anchor point. If you need a real
% convolution, flip the kernel using flip() and set the new anchor to
% (kernel.cols - anchor.x - 1, kernel.rows - anchor.y - 1).
%
% The function uses the DFT-based algorithm in case of sufficiently large
% kernels (~``11 x 11`` or larger) and the direct algorithm (that uses the
% engine retrieved by createLinearFilter() ) for small kernels.
%
