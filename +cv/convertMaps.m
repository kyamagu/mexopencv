%CONVERTMAPS  Converts image transformation maps from one representation to another
%
%    [dstmap1, dstmap2] = cv.convertMaps(map1, map2)
%    [dstmap1, dstmap2] = cv.convertMaps(map1)
%    [...] = cv.convertMaps(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __map1__ The first input map of either (x,y) points or just x values of
%       the transformation having the type `int16` (MxNx2), `single` (MxN), or
%       `single` (MxNx2).
% * __map2__ The second input map of y values of the transformation having the
%       type `uint16` (MxN) or `single` (MxN), or none (empty map if `map1` is
%       (x,y) points), respectively.
%
% ## Output
% * __dstmap1__ The first output map that has the type specified by
%       `DstMap1Type` and the same row/col size as `src`. See details below.
% * __dstmap2__ The second output map. See details below.
%
% ## Options
% * __DstMap1Type__ Type of the first output map. The default value of -1
%       chooses an appropriate type depending on the direction of conversion.
%       So if `map1` is in fixed-point representation, the output type is
%       'single2' (for combined floating-point representation), otherwise if
%       `map1` is in floating-point representation, the output type is `int16'
%       (for fixed-point representation). Accepted types are:
%       * __int16__ first output map is a MxNx2 `int16` array
%       * __single1__ first output map is a MxNx1 `single` matrix
%       * __single2__ first output map is a MxNx2 `single` matrix
% * __NNInterpolation__ Flag indicating whether the fixed-point maps are used
%       for the nearest-neighbor or for a more complex interpolation. If this
%       flag is true, the second output will be empty. default false
%
% The function converts a pair of maps for cv.remap from one representation to
% another. The following options `(map1, map2) -> (dstmap1, dstmap2)` are
% supported (in terms of class and number of channels of maps):
%
% * `(single 1-cn, single 1-cn) -> (int16 2-cn, uint16 1-cn)`: This is the
%   most frequently used conversion operation, in which the original
%   floating-point maps (see cv.remap) are converted to a more compact and
%   much faster fixed-point representation. The first output array contains
%   the rounded coordinates and the second array (created only when
%   `NNInterpolation=false`) contains indices in the interpolation tables.
%
% * `(single 2-cn, []) -> (int16 2-cn, uint16 1-cn)`: The same as above but
%   the original maps are stored in one 2-channel matrix.
%
% * `(int16 2-cn, uint16 1-cn) -> (single 1-cn, single 1-cn)` or
%   `(int16 2-cn, uint16 1-cn) -> (single 2-cn, [])`: Reverse conversion.
%   Obviously, the reconstructed floating-point maps will not be exactly the
%   same as the originals.
%
% See also: cv.remap, cv.undistort, cv.initUndistortRectifyMap
%
