%SEPFILTER2D  Applies a separable linear filter to an image
%
%    dst = cv.sepFilter2D(src, kernelX, kernelY)
%    dst = cv.sepFilter2D(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __kernelX__ Coefficients for filtering each row.
% * __kernelY__ Coefficients for filtering each column.
%
% ## Output
% * __dst__ Destination image of the same size and the same number of channels
%       as `src`.
%
% ## Options
% * __Anchor__ Anchor position within the kernel. The default value (-1,-1)
%       means that the anchor is at the kernel center.
% * __Delta__ Value added to the filtered results before storing them.
%       default 0
% * __BorderType__ Pixel extrapolation method. default 'Default'
% * __DDepth__ Destination image depth, see cv.filter2D. default -1
%
% The function applies a separable linear filter to the image. That is, first,
% every row of `src` is filtered with the 1D kernel `kernelX`. Then, every
% column of the result is filtered with the 1D kernel `kernelY`. The final
% result shifted by delta is stored in `dst`.
%
% See also: cv.filter2D, cv.Sobel, cv.GaussianBlur, cv.boxFilter, cv.blur
%
