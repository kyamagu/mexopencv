%MATCHTEMPLATE  Compares a template against overlapped image regions
%
%    result = cv.matchTemplate(image, tmpl)
%    result = cv.matchTemplate(image, tmpl, 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ Image where the search is running.  It must be 8-bit integer or
%       32-bit floating-point.
% * __tmpl__ Searched template. It must be not greater than the source `image`
%         and have the same data type.
%
% ## Output
% * __result__ Map of comparison results. It is single-channel 32-bit
%         floating-point. If `image` is `W x H` and `templ` is `w x h`, then
%         result is `(W-w+1) x (H-h+1)`.
%
% ## Options
% * __Method__ Parameter specifying the comparison method, default 'SqDiff'.
%       One of the following:
%       * __SqDiff__        Squared difference
%       * __SqDiffNormed__  Normalized squared difference
%       * __CCorr__         Cross correlation
%       * __CCorrNormed__   Normalized cross correlation
%       * __CCoeff__        Cosine coefficient
%       * __CCoeffNormed__  Normalized cosine coefficient
% * __Mask__ Mask of searched template. It must have the same datatype and
%         size with `templ`. It is not set by default.
%
% The function slides through `image`, compares the overlapped patches of size
% `w x h` against `templ` using the specified method and stores the comparison
% results in `result`.
%
% Here are the formulae for the available comparison methods (`I` denotes
% image, `T` template, `R` result). The summation is done over template and/or
% the image patch: `x'=0..w-1`, `y'=0..h-1`:
%
% * __SqDiff__:
%
%        R(x,y) = \sum_{x',y'} (T(x',y') - I(x+x',y+y'))^2
%
% * __SqDiffNormed__:
%
%        R(x,y) = \sum_{x',y'} (T(x',y') - I(x+x',y+y'))^2 /
%                 sqrt(\sum_{x',y'} (T(x',y')^2) * sum_{x',y'} (I(x+x',y+y')^2))
%
% * __CCorr__:
%
%        R(x,y) = \sum_{x',y'} (T(x',y') * I(x+x',y+y'))
%
% * __CCorrNormed__:
%
%        R(x,y) = \sum_{x',y'} (T(x',y') * I(x+x',y+y')) /
%                 sqrt(\sum_{x',y'} (T(x',y')^2) * sum_{x',y'} (I(x+x',y+y')^2))
%
% * __CCoeff__:
%
%        R(x,y) = \sum_{x',y'} (T'(x',y') * I'(x+x',y+y')), where
%
%        T'(x',y') = T(x',y') - 1 / (w*h) * \sum_{x'',y''} T(x'',y'')
%        I'(x+x',y+y') = I(x+x',y+y') - 1 / (w*h) * \sum_{x'',y''} I(x+x'',y+y'')
%
% * __CCoeffNormed__:
%
%        R(x,y) = \sum_{x',y'} (T'(x',y') * I'(x+x',y+y')) /
%                 sqrt(\sum_{x',y'} (T'(x',y')^2) * sum_{x',y'} (I'(x+x',y+y')^2))
%
% After the function finishes the comparison, the best matches can be found as
% global minimums (when 'SqDiff' was used) or maximums (when 'CCorr' or
% 'CCoeff' was used) using the `min` and `max` functions. In case of a color
% image, template summation in the numerator and each sum in the denominator
% is done over all of the channels and separate mean values are used for each
% channel. That is, the function can take a color template and a color image.
% The result will still be a single-channel image, which is easier to analyze.
%
% See also: normxcorr2, xcorr2, conv2, filter2, vision.TemplateMatcher
%
