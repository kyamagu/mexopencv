%PUTTEXT  Draws a text string
%
%    img = cv.putText(img, txt, org)
%    [...] = cv.putText(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __txt__ Text string to be drawn.
% * __org__ Bottom-left corner of the text string in the image. `[x,y]`
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __FontFace__ Font to use. One of the following:
%     * `'HersheySimplex'` (default)
%     * `'HersheyPlain'`
%     * `'HersheyDuplex'`
%     * `'HersheyComplex'`
%     * `'HersheyTriplex'`
%     * `'HersheyComplexSmall'`
%     * `'HersheyScriptSimplex'`
%     * `'HersheyScriptComplex'`
% * __FontStyle__ Font style. One of 'Regular' (default) or 'Italic'
% * __FontScale__ Font scale factor that is multiplied by the
%        font-specific base size. default 1.0
% * __Color__ 3-element floating point vector specifying text color.
% * __Thickness__ Thickness of the lines used to draw a text. default 1.
% * __LineType__ Type of the line boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
% * __BottomLeftOrigin__ When true, the image data origin is at the
%        bottom-left corner. Otherwise, it is at the top-left corner.
%        default false.
%
% The function `putText` renders the specified text string in the image.
% Symbols that cannot be rendered using the specified font are replaced by
% question marks.
%
% See also cv.getTextSize
%
