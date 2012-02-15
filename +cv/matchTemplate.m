%MATCHTEMPLATE  Compares a template against overlapped image regions
%
%    result = cv.matchTemplate(image, tmpl)
%    result = cv.matchTemplate(image, tmpl, 'Method', methodValue)
%
% ## Input
% * __image__ Image where the search is running.
% * __tmpl__ Searched template. It must be not greater than the source image and
%         have the same data type.
%
% ## Output
% * __result__ Map of comparison results. It is single-channel 32-bit
%         floating-point. If image is W x H and templ is w x h, then result is
%         (W-w+1) x (H-h+1).
%
% ## Options
% * __Method__ Parameter specifying the comparison method. One of the following:
%         'SqDiff'        Squared difference
%         'SqDiffNormed'  Normalized squared difference
%         'CCorr'         Cross correlation
%         'CCorrNormed'   Normalized cross correlation
%         'CCoeff'        Cosine efficient
%         'CCoeffNormed'  Normalized cosine efficient
%
% The function slides through image, compares the overlapped patches of size w
% x h against templ using the specified method and stores the comparison results
% in result.
%
% After the function finishes the comparison, the best matches can be found as
% global minimums (when 'SqDiff' was used) or maximums (when 'CCorr' or 'CCoeff'
% was used) using the min() max() function. In case of a color image, template
% summation in the numerator and each sum in the denominator is done over all
% of the channels and separate mean values are used for each channel. That is,
% the function can take a color template and a color image. The result will
% still be a single-channel image, which is easier to analyze.
%
