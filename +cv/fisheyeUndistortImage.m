%FISHEYEUNDISTORTIMAGE  Transforms an image to compensate for fisheye lens distortion
%
%     undistorted = cv.fisheyeUndistortImage(distorted, K, D)
%     undistorted = cv.fisheyeUndistortImage(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __distorted__ image with fisheye lens distortion.
% * __K__ Camera matrix 3x3, `K = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __D__ Input vector of distortion coefficients `[k1,k2,k3,k4]`.
%
% ## Output
% * __undistorted__ Output image with compensated fisheye lens distortion.
%
% ## Options
% * __NewCameraMatrix__ Camera matrix of the distorted image. By default, it
%   is the identity matrix but you may additionally scale and shift the result
%   by using a different matrix.
% * __NewImageSize__ Image size after rectification `[w,h]`. By default, it is
%   set to input image size.
%
% The function transforms an image to compensate radial and tangential lens
% distortion.
%
% The function is simply a combination of cv.fisheyeInitUndistortRectifyMap
% (with unity `R`) and cv.remap (with bilinear interpolation). See the former
% function for details of the transformation being performed.
%
% See below the results of cv.fisheyeUndistortImage:
%
% * a) result of cv.undistort of perspective camera model (all possible
%   coefficients `[k1, k2, k3, k4, k5, k6]` of distortion were optimized under
%   calibration)
% * b) result of cv.fisheyeUndistortImage of fisheye camera model (all
%   possible coefficients `[k1, k2, k3, k4]` of fisheye distortion were
%   optimized under calibration)
% * c) original image was captured with fisheye lens
%
% Pictures a) and b) almost the same. But if we consider points of image
% located far from the center of image, we can notice that on image a) these
% points are distorted.
%
% ![image](https://docs.opencv.org/3.3.1/fisheye_undistorted.jpg)
%
% See also: cv.fisheyeInitUndistortRectifyMap, cv.remap, cv.undistort
%
