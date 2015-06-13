%NORMALIZE  Normalizes the norm or value range of an array
%
%    dst = cv.normalize(src)
%    dst = cv.normalize(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ input array.
%
% ## Output
% * __dst__ output array of the same size as `src`. See `DType` option.
%
% ## Options
% * __Alpha__ norm value to normalize to or the lower range boundary in case
%       of the range normalization. default 1
% * __Beta__ upper range boundary in case of the range normalization; it is
%       not used for the norm normalization. default 0
% * __NormType__ normalization type, default 'L2'. One of:
%       * __Inf__
%       * __L1__
%       * __L2__
%       * __MinMax__
% * __DType__ when negative, the output array has the same type as `src`;
%       otherwise, it has the same number of channels as `src` and the
%       specified depth (a numeric class name: 'uint8', 'double', etc...).
%       default -1
% * __Mask__ optional operation mask. Not set by default.
% * __Dest__ initial array used for output. This can initialize `dst` when
%       `Mask` is used. Not set by default.
%
% The functions cv.normalize scale and shift the input array elements so that:
%
%    ||dst||_Lp = alpha
%
% (where `p`=Inf, 1 or 2) when `NormType`='Inf', 'L1', or 'L2', respectively;
% or so that:
%
%    min(dst) = alpha, max(dst) = beta
%
% when `NormType`='MinMax' (for dense arrays only). The optional `Mask`
% specifies a sub-array to be normalized. This means that the norm or min-max
% are calculated over the sub-array, and then this sub-array is modified to be
% normalized. If you want to only use the mask to calculate the norm or
% min-max but modify the whole array, you can use cv.norm and Mat::convertTo.
%
% See also: cv.norm, norm, min, max
%
