%GETTEXTSIZE  Calculates the width and height of a text string
%
%   [siz, baseLine] = cv.getTextSize(text)
%   [...] = cv.getTextSize(..., 'OptionName', optionValue, ...)
%
% Input:
%    text: Text string.
% Output:
%    siz: Size of the text.
%    baseLine: y-coordinate of the baseline relative to the bottom-most
%        text point.
% Options:
%    'FontFace': Font to use. One of the following:
%        'HersheySimplex' (default)
%        'HersheyPlain'
%        'HersheyDuplex'
%        'HersheyComplex'
%        'HersheyTriplex'
%        'HersheyComplexSmall'
%        'HersheyScriptSimplex'
%        'HersheyScriptComplex'
%    'FontStyle': Font style. One of 'Regular' (default) or 'Italic'
%    'Thickness': Thickness of lines used to render the text. default 1
%
% The function getTextSize calculates and returns the size of a box that
% contains the specified text.
%
% See also cv.putText
%