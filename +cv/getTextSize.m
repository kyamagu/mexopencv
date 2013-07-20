%GETTEXTSIZE  Calculates the width and height of a text string
%
%    [siz, baseLine] = cv.getTextSize(text)
%    [...] = cv.getTextSize(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __text__ Text string.
%
% ## Output
% * __siz__ Size of of a box that contains the specified text
%        (`[width,height]`).
% * __baseLine__ y-coordinate of the baseline relative to the bottom-most
%        text point.
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
% * __Thickness__ Thickness of lines used to render the text. default 1
%
% The function cv.getTextSize calculates and returns the size of a box that
% contains the specified text.
%
% ## Example
% The following code renders some text, the tight box surrounding it, and
% the baseline:
%
%    txt = 'Funny text inside the box';
%    fontFace = 'HersheyScriptSimplex';
%    fontScale = 2;
%    thickness = 3;
%
%    img = zeros(300,800,3, 'uint8');
%
%    [textSize,baseline] = cv.getTextSize(txt, 'FontFace',fontFace, ...
%        'FontScale',fontScale, 'Thickness',thickness);
%    baseline = baseline + thickness;
%
%    % center the text
%    textOrg = [size(img,2) - textSize(1), size(img,1) + textSize(2)] ./ 2;
%
%    % draw the box
%    img = cv.rectangle(img, textOrg + [0, baseline], ...
%        textOrg + [textSize(1), -textSize(2)], 'Color',[0,0,255]);
%
%    % ... and the baseline first
%    img = cv.line(img, textOrg + [0, thickness], ...
%        textOrg + [textSize(1), thickness], 'Color',[0,255,0]);
%
%    % then put the text itself
%    img = cv.putText(img, txt, textOrg, 'Color',[255,255,255], ...
%        'Thickness',thickness, 'FontFace',fontFace, 'FontScale',fontScale);
%
%    imshow(img, 'InitialMagnification',100, 'Border','tight')
%
%
% See also cv.putText
%
