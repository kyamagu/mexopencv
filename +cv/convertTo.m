%CONVERTTO  Converts an array to another data type with optional scaling
%
%     dst = cv.convertTo(src)
%     dst = cv.convertTo(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input matrix.
%
% ## Output
% * __dst__ Output image of the same size as `src`, and the specified type.
%
% ## Options
% * __RType__ desired output matrix type (`uint8`, `int32`, `double`, etc.),
%   or rather the depth since the number of channels are the same as the input
%   has; if it is negative, the output matrix will have the same type as the
%   input. Default -1
% * __Alpha__ optional scale factor. default 1.0
% * __Beta__ optional delta added to the scaled values. default 0.0
%
% The method converts source pixel values to the target data type.
% Saturation is applied at the end to avoid possible overflows:
%
%     dst = cast(src*alpha + beta, RType);
%
% See also: cv.copyTo, cv.normalize, cast, typecast, im2double, im2uint8,
%  mat2gray
%
