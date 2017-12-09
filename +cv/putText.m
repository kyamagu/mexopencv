%PUTTEXT  Draws a text string
%
%     img = cv.putText(img, txt, org)
%     [...] = cv.putText(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __txt__ Text string to be drawn.
% * __org__ Bottom-left corner of the text string in the image `[x,y]`.
%
% ## Output
% * __img__ Output image, same size and type as input `img`.
%
% ## Options
% * __FontFace__ Font type to use. One of the following:
%   * __HersheySimplex__ Normal size sans-serif (default)
%   * __HersheyPlain__ Small size sans-serif
%   * __HersheyDuplex__ Normal size sans-serif; more complex than
%     `HersheySimplex`
%   * __HersheyComplex__ Normal size serif; more complex than `HersheyDuplex`
%   * __HersheyTriplex__ Normal size serif; more complex than `HersheyComplex`
%   * __HersheyComplexSmall__ Smaller version of `HersheyComplex`
%   * __HersheyScriptSimplex__ Handwriting style
%   * __HersheyScriptComplex__ More complex variant of `HersheyScriptSimplex`
% * __FontStyle__ Font style. One of:
%   * __Regular__ (default)
%   * __Italic__
% * __FontScale__ Font scale factor that is multiplied by the font-specific
%   base size. default 1.0
% * __Color__ 3-element floating-point vector specifying text color.
% * __Thickness__ Thickness of the lines used to draw a text. default 1.
% * __LineType__ Line type (see cv.line). One of:
%   * __4__ 4-connected line
%   * __8__ 8-connected line (default)
%   * __AA__ anti-aliased line
% * __BottomLeftOrigin__ When true, the image data origin is at the
%   bottom-left corner. Otherwise, it is at the top-left corner. default false
%
% The function cv.putText renders the specified text string in the image.
% Symbols that cannot be rendered using the specified font are replaced by
% question marks. See cv.getTextSize for a text rendering code example.
%
% See also: cv.getTextSize
%
