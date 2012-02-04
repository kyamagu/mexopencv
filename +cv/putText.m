%PUTTEXT  Draws a text string
%
%   img = cv.putText(img, txt, org)
%   [...] = cv.putText(..., 'OptionName', optionValue, ...)
%
% Input:
%    img: Image.
%    txt: Text string to be drawn.
%    org: Bottom-left corner of the text string in the image. [x,y]
% Output:
%    img: Output image.
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
%    'Color': 3-element floating point vector specifying text color.
%    'Thickness': Thickness of the lines used to draw a text. default 1.
%    'LineType': Type of the line boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
%    'BottomLeftOrigin': When true, the image data origin is at the
%        bottom-left corner. Otherwise, it is at the top-left corner.
%        default false.
%
% The function putText renders the specified text string in the image.
% Symbols that cannot be rendered using the specified font are replaced by
% question marks.
%
% See also cv.getTextSize
%