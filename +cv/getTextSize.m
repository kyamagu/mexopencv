%GETTEXTSIZE  Calculates the width and height of a text string
%
%    [siz, baseLine] = cv.getTextSize(text)
%    [...] = cv.getTextSize(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __text__ Text string.
%
% ## Output
% * __siz__ Size of the text.
% * __baseLine__ y-coordinate of the baseline relative to the bottom-most
%        text point.
%
% ## Options
% * __FontFace__ Font to use. One of the following:
%        'HersheySimplex' (default)
%        'HersheyPlain'
%        'HersheyDuplex'
%        'HersheyComplex'
%        'HersheyTriplex'
%        'HersheyComplexSmall'
%        'HersheyScriptSimplex'
%        'HersheyScriptComplex'
% * __FontStyle__ Font style. One of 'Regular' (default) or 'Italic'
% * __Thickness__ Thickness of lines used to render the text. default 1
%
% The function getTextSize calculates and returns the size of a box that
% contains the specified text.
%
% See also cv.putText
%
