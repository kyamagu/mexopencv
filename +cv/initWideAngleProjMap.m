%INITWIDEANGLEPROJMAP  initializes maps for cv.remap for wide-angle
%
%    [map1, map2] = cv.initWideAngleProjMap(cameraMatrix, distCoeffs, imageSize, destImageWidth)
%    [map1, map2, scale] = cv.initWideAngleProjMap(cameraMatrix, distCoeffs, imageSize, destImageWidth)
%    [...] = cv.initWideAngleProjMap(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __cameraMatrix__ Input camera matrix `A = [f_x 0 c_x; 0 f_y c_y; 0 0 1]`
% * __distCoeffs__ Input vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8, or 12 elements. If
%       the vector is empty, the zero distortion coefficients are assumed.
% * __imageSize__ image size `[w,h]`.
% * __destImageWidth__
%
% ## Output
% * __map1__ The first output map. See `M1Type`.
% * __map2__ The second output map. See `M1Type`.
% * __scale__
%
% ## Options
% * __M1Type__ Type of the first output map, default `single2`. See
%       cv.convertMaps. Accepted types are:
%       * __int16__ first output map is a MxNx2 `int16` array, second output
%             map is MxNx1 `uint16` (fixed-point representation).
%       * __single1__ first output map is a MxNx1 `single` matrix, second
%             output map is MxNx1 `single` (separate floating-point
%             representation).
%       * __single2__ first output map is a MxNx2 `single` matrix, second
%             output map is empty (combined floating-point representation).
% * __ProjType__ projection type, default 'EqRect'. One of:
%       * __Ortho__
%       * __EqRect__
% * __Alpha__ default 0
%
% See also: cv.initUndistortRectifyMap, cv.remap, cv.convertMaps
%
