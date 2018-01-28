%FISHEYEESTIMATENEWCAMERAMATRIXFORUNDISTORTRECTIFY  Estimates new camera matrix for undistortion or rectification (fisheye)
%
%     P = cv.fisheyeEstimateNewCameraMatrixForUndistortRectify(K, D, imageSize)
%     [...] = cv.fisheyeEstimateNewCameraMatrixForUndistortRectify(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __K__ Camera matrix 3x3, `K = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __D__ Input vector of distortion coefficients `[k1,k2,k3,k4]`.
% * __imageSize__ Size of the image `[w,h]`.
%
% ## Output
% * __P__ New camera matrix (3x3).
%
% ## Options
% * __R__ Rectification transformation in the object space
%   (3x3 matrix or 1x3/3x1 vector).
% * __Balance__ Sets the new focal length in range between the min focal
%   length and the max focal length. Balance is in range of [0,1]. default 0
% * __NewImageSize__ Image size after rectification `[w,h]`. By default, it is
%   set to `imageSize`.
% * __FOVScale__ Divisor for new focal length. default 1.0
%
% See also: cv.fisheyeInitUndistortRectifyMap, cv.getOptimalNewCameraMatrix
%
