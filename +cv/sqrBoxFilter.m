%SQRBOXFILTER  Calculates the normalized sum of squares of the pixel values overlapping the filter
%
%    dst = cv.sqrBoxFilter(src)
%    dst = cv.sqrBoxFilter(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image.
%
% ## Output
% * __dst__ output image of the same size as `src` and the type specified.
%
% ## Options
% * __DDepth__ the output image depth (-1 to use `class(src)`). Default -1,
%       which chooses between `single` or `double` (`double` if input image is
%       also `double`, `single` otherwise). See cv.filter2D for details.
% * __KSize__ kernel size. Default [5,5]
% * __Anchor__ kernel anchor point `[x,y]`. The default value [-1,-1] denotes
%       that the anchor is at the kernel center
% * __Normalize__ flag, specifying whether the kernel is normalized by its
%       area or not. default true
% * __BorderType__ border mode used to extrapolate pixels outside of the
%       image. See cv.copyMakeBorder. Default 'Default'
%
% For every pixel (x,y) in the source image, the function calculates the sum
% of squares of those neighboring pixel values which overlap the filter placed
% over the pixel (x,y).
%
% The unnormalized square box filter can be useful in computing local image
% statistics such as the the local variance and standard deviation around the
% neighborhood of a pixel.
%
% See also: cv.boxFilter
%
