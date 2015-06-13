%COPYMAKEBORDER  Forms a border around an image.
%
%    dst = cv.copyMakeBorder(src, top, bottom, left, right)
%    [...] = cv.copyMakeBorder(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __top__, __bottom__, __left__, __right__ Parameter specifying how many
%       pixels in each direction from the source image rectangle to extrapolate.
%       For example, `top=1`, `bottom=1`, `left=1`, `right=1` mean that
%       1 pixel-wide border needs to be built.
%
% ## Output
% * __dst__ Destination image of the same type as `src` and the size
%       `[size(src,1)+top+bottom, size(src,2)+left+right, size(src,3)]`.
%
% ## Options
% * __BorderType__ Border type. See cv.borderInterpolate for details.
% * __Value__ Border value if `BorderType=='Constant'`
%
% The function copies the source image into the middle of the destination image.
% The areas to the left, to the right, above and below the copied source image
% will be filled with extrapolated pixels. This is not what filtering functions
% based on it do (they extrapolate pixels on-fly), but what other more complex
% functions, including your own, may do to simplify image boundary handling.
%
% See also: cv.borderInterpolate
%
