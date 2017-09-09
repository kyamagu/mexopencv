%CONVERTFP16  Converts an array to half precision floating number
%
%     dst = cv.convertFp16(src)
%
% ## Input
% * __src__ input array.
%
% ## Output
% * __dst__ output array.
%
% This function converts FP32 (single precision floating point) from/to FP16
% (half precision floating point). The input array has to have type of
% `single` or `int16` to represent the bit depth. If the input array is
% neither of them, the function will raise an error. The format of half
% precision floating point is defined in IEEE 754-2008.
%
% See also: cv.convertTo
%
