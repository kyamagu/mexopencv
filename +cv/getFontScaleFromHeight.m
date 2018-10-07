%GETFONTSCALEFROMHEIGHT  Calculates the font-specific size to use to achieve a given height in pixels
%
%     fontScale = cv.getFontScaleFromHeight(pixelHeight)
%     fontScale = cv.getFontScaleFromHeight(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __pixelHeight__ Pixel height to compute the `fontScale` for.
%
% ## Output
% * __fontScale__ The font size to use for cv.putText
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
% * __Thickness__ Thickness of lines used to render the text. default 1
%
% See also: cv.putText, cv.getTextSize
%
