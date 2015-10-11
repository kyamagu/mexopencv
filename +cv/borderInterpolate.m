%BORDERINTERPOLATE  Computes the source location of an extrapolated pixel.
%
%    loc = cv.borderInterpolate(p, len)
%    [...] = cv.borderInterpolate(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __p__ 0-based coordinate of the extrapolated pixel along one of the axes,
%       likely `p < 0` or `p >= len`.
% * __len__ Length of the array along the corresponding axis.
%
% ## Output
% * __loc__ Pixel coordinate along the specified axis.
%
% ## Options
% * __BorderType__ Border type, one of:
%       * __Constant__ `iiiiii|abcdefgh|iiiiiii` with some specified `i`
%       * __Replicate__ `aaaaaa|abcdefgh|hhhhhhh`
%       * __Reflect__ `fedcba|abcdefgh|hgfedcb`
%       * __Reflect101__ `gfedcb|abcdefgh|gfedcba`
%       * __Wrap__ `cdefgh|abcdefgh|abcdefg`
%       * __Default__ same as 'Reflect101' (default)
%       When `BorderType=='Constant'`, the function always returns -1,
%       regardless of `p` and `len`.
%
% The function computes and returns the coordinate of a donor pixel
% corresponding to the specified extrapolated pixel when using the specified
% extrapolation border mode.
%
% Normally, the function is not called directly. It is used inside filtering
% functions and also in cv.copyMakeBorder.
%
% See also: cv.copyMakeBorder
%
