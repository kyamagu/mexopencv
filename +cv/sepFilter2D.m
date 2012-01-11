%SEPFILTER2D  Applies a separable linear filter to an image
%
%    dst = sepFilter2D(src, rowKernel, columnKernel)
%    dst = sepFilter2D(src, rowKernel, columnKernel, 'Anchor', [0,1], ...)
%
%  Input:
%    src: Source image.
%    rowKernel: Coefficients for filtering each row.
%    columnKernel: Coefficients for filtering each column.
%  Output:
%    dst: Destination image of the same size and the same number of channels as src.
%  Options:
%    'Anchor': Anchor position within the kernel. The default value (-1,-1)
%              means that the anchor is at the kernel center.
%    'Delta': Value added to the filtered results before storing them.
%    'BorderType': Pixel extrapolation method
%