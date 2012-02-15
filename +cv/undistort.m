%UNDISTORT  Transforms an image to compensate for lens distortion
%
%    dst = cv.undistort(src, cameraMatrix, distCoeffs)
%    dst = cv.undistort(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input (distorted) image.
% * __cameraMatrix__ Input camera matrix A = [fx,0,cx;0,fy,cy;0,0,1].
% * __distCoeffs__ Input vector of distortion coefficients [k1,k2,p1,p2,k3,k4,k5,
%        k6] of 4, 5, or 8 elements. If the vector is empty, the zero distortion
%        coefficients are assumed.
%
% ## Output
% * __dst__ Output (corrected) image that has the same size and type as src.
%
% ## Options
% * __NewCameraMatrix__ Camera matrix of the distorted image. By default, it is
%        the same as cameraMatrix but you may additionally scale and shift the
%        result by using a different matrix.
%
% The function transforms an image to compensate radial and tangential lens
% distortion.
%
% The function is simply a combination of cv.initUndistortRectifyMap (with unity
% R) and cv.remap (with bilinear interpolation). See the former function for
% details of the transformation being performed.
%
% Those pixels in the destination image, for which there is no correspondent
% pixels in the source image, are filled with zeros (black color).
%
% A particular subset of the source image that will be visible in the corrected
% image can be regulated by newCameraMatrix . You can use
% cv.getOptimalNewCameraMatrix to compute the appropriate newCameraMatrix
% depending on your requirements.
%
% The camera matrix and the distortion parameters can be determined using
% cv.calibrateCamera. If the resolution of images is different from the
% resolution used at the calibration stage, and need to be scaled accordingly,
% while the distortion coefficients remain the same.
%
% See also cv.undistortPoints cv.calibrateCamera
%
