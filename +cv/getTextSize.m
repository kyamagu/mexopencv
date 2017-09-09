%GETTEXTSIZE  Calculates the width and height of a text string
%
%     [siz, baseLine] = cv.getTextSize(text)
%     [...] = cv.getTextSize(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __text__ Input text string.
%
% ## Output
% * __siz__ Size of a box that contains the specified text `[w,h]`.
% * __baseLine__ y-coordinate of the baseline relative to the bottom-most
%   text point. The baseline is the line on which the bottoms of characters
%   such as 'a' and 'b' are aligned. Characters such as 'y' and 'g' hang below
%   the baseline.
%
% ## Options
% * __FontFace__ Font to use. One of the following:
%   * __HersheySimplex__ (default)
%   * __HersheyPlain__
%   * __HersheyDuplex__
%   * __HersheyComplex__
%   * __HersheyTriplex__
%   * __HersheyComplexSmall__
%   * __HersheyScriptSimplex__
%   * __HersheyScriptComplex__
% * __FontStyle__ Font style. One of:
%   * __Regular__ (default)
%   * __Italic__
% * __FontScale__ Font scale factor that is multiplied by the font-specific
%   base size. default 1.0
% * __Thickness__ Thickness of lines used to render the text. default 1
%
% The function cv.getTextSize calculates and returns the size of a box that
% contains the specified text.
%
% ## Example
% Refer to the `draw_text_demo.m` sample. The code renders some text, the
% tight box surrounding it, and the baseline.
%
% See also: cv.putText
%
