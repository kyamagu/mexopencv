%CONVERTSCALEABS  Scales, calculates absolute values, and converts the result to 8-bit
%
%    dst = cv.convertScaleAbs(src)
%    dst = cv.convertScaleAbs(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input array.
%
% ## Output
% * __dst__ output 8-bit array.
%
% ## Options
% * __Alpha__ optional scale factor. Default 1.0
% * __Beta__ optional delta added to the scaled values. Default 0.0
%
% On each element of the input array, the function cv.convertScaleAbs performs
% three operations sequentially: scaling, taking an absolute value, conversion
% to an unsigned 8-bit type:
%
%    dst(I) = saturate_cast<uchar>(|src(I) * alpha + beta|)
%
% In case of multi-channel arrays, the function processes each channel
% independently. When the output is not 8-bit, the operation can be emulated
% by calling the `Mat::convertTo` method (or by using matrix expressions) and
% then by calculating an absolute value of the result.
%
% See also: abs, uint8, cast
%
