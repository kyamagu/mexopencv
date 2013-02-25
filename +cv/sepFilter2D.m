%SEPFILTER2D  Applies a separable linear filter to an image
%
%    dst = cv.sepFilter2D(src, rowKernel, columnKernel)
%    dst = cv.sepFilter2D(src, rowKernel, columnKernel, 'Anchor', [0,1], ...)
%
% ## Input
% * __src__ Source image.
% * __rowKernel__ Coefficients for filtering each row.
% * __columnKernel__ Coefficients for filtering each column.
%
% ## Output
% * __dst__ Destination image of the same size and the same number of channels as src.
%
% ## Options
% * __Anchor__ Anchor position within the kernel. The default value (-1,-1)
%              means that the anchor is at the kernel center.
% * __Delta__ Value added to the filtered results before storing them.
% * __BorderType__ Pixel extrapolation method
%
% See also cv.filter2D
%
