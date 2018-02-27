%FISHEYEINITUNDISTORTRECTIFYMAP  Computes undistortion and rectification maps (fisheye)
%
%     [map1, map2] = cv.fisheyeInitUndistortRectifyMap(K, D, siz)
%     [...] = cv.fisheyeInitUndistortRectifyMap(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __K__ Camera matrix 3x3, `K = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __D__ Input vector of distortion coefficients `[k1,k2,k3,k4]`.
% * __size__ Undistorted image size `[w,h]`.
%
% ## Output
% * __map1__ The first output map. See `M1Type`.
% * __map2__ The second output map. See `M1Type`.
%
% ## Options
% * __R__ Rectification transformation in the object space
%   (3x3 matrix or 1x3/3x1 vector).
% * __P__ New camera matrix (3x3) or new projection matrix (3x4).
% * __M1Type__ Type of the first output map, default -1 (equivalent to
%   `int16`). See cv.convertMaps for details. One of:
%   * __int16__ (fixed-point representation).
%   * __single1__ (separate floating-point representation).
%
% The function computes undistortion and rectification maps for image
% transform by cv.remap. If `D` is empty zero distortion is used, if `R` or
% `P` is empty identity matrixes are used.
%
% See also: cv.initUndistortRectifyMap, cv.remap, cv.convertMaps
%
