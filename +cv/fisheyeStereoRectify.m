%FISHEYESTEREORECTIFY  Stereo rectification for fisheye camera model
%
%     S = cv.fisheyeStereoRectify(K1, D1, K2, D2, imageSize, R, T)
%     [...] = cv.fisheyeStereoRectify(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __K1__ First camera matrix 3x3.
% * __D1__ First camera distortion parameters of 4 elements.
% * __K2__ Second camera matrix 3x3.
% * __D2__ Second camera distortion parameters of 4 elements.
% * __imageSize__ Size of the image used for stereo calibration `[w,h]`.
% * __R__ Rotation matrix between the coordinate systems of the first and the
%   second cameras, 3x3/3x1 (see cv.Rodrigues).
% * __T__ Translation vector between coordinate systems of the cameras, 3x1.
%
% ## Output
% * __S__ scalar struct having the following fields:
%   * __R1__ 3x3 rectification transform (rotation matrix) for the first
%     camera.
%   * __R2__ 3x3 rectification transform (rotation matrix) for the second
%     camera.
%   * __P1__ 3x4 projection matrix in the new (rectified) coordinate systems
%     for the first camera.
%   * __P2__ 3x4 projection matrix in the new (rectified) coordinate systems
%     for the second camera.
%   * __Q__ 4x4 disparity-to-depth mapping matrix (see cv.reprojectImageTo3D).
%
% ## Options
% * __ZeroDisparity__ If the flag is set, the function makes the principal
%   points of each camera have the same pixel coordinates in the rectified
%   views. And if the flag is not set, the function may still shift the images
%   in the horizontal or vertical direction (depending on the orientation of
%   epipolar lines) to maximize the useful image area. default true
% * __NewImageSize__ New image resolution after rectification. The same size
%   should be passed to cv.fisheyeInitUndistortRectifyMap. When [0,0] is
%   passed (default), it is set to the original `imageSize`. Setting it to
%   larger value can help you preserve details in the original image,
%   especially when there is a big radial distortion.
% * __Balance__ Sets the new focal length in range between the min focal
%   length and the max focal length. Balance is in range of [0,1]. default 0
% * __FOVScale__ Divisor for new focal length. default 1.0
%
% See also: cv.fisheyeStereoCalibrate, cv.stereoRectify
%
