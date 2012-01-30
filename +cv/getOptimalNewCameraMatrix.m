%GETOPTIMALNEWCAMERAMATRIX  Returns the new camera matrix based on the free scaling parameter
%
%   cameraMatrix = cv.getOptimalNewCameraMatrix(cameraMatrix, distCoeffs, imageSize)
%   [cameraMatrix, validPixROI] = cv.getOptimalNewCameraMatrix(...)
%   [...] = cv.getOptimalNewCameraMatrix(..., 'OptionName', optionValue, ...)
%
% Input:
%    cameraMatrix: Input camera matrix.
%    distCoeffs: Input vector of distortion coefficients [k1,k2,p1,p2,k3,
%        k4,k5,k6] of 4, 5, or 8 elements. If the vector is NULL/empty, the
%        zero distortion coefficients are assumed.
%    imageSize: Original image size [w,h].
% Output:
%    cameraMatrix: New camera matrix.
%    validPixROI: rectangle that outlines all-good-pixels region in the
%        undistorted image. See roi1, roi2 description in cv.stereoRectify.
% Options:
%    'Alpha': Free scaling parameter between 0 (when all the pixels in the
%        undistorted image are valid) and 1 (when all the source image
%        pixels are retained in the undistorted image). default 0.8.
%    'NewImageSize': Image size after rectification. By default,it is set
%        to imageSize.
%    'CenterPrincipalPoint': Optional flag that indicates whether in the
%        new camera matrix the principal point should be at the image
%        center or not. By default, the principal point is chosen to best
%        fit a subset of the source image (determined by alpha) to the
%        corrected image. default false.
%
% The function computes and returns the optimal new camera matrix based on
% the free scaling parameter. By varying this parameter, you may retrieve
% only sensible pixels alpha=0 , keep all the original image pixels if
% there is valuable information in the corners alpha=1 , or get something
% in between. When alpha>0 , the undistortion result is likely to have some
% black pixels corresponding to ?virtual? pixels outside of the captured
% distorted image. The original camera matrix, distortion coefficients,
% the computed new camera matrix, and newImageSize should be passed to
% cv.initUndistortRectifyMap to produce the maps for cv.remap.
%
% See also cv.stereoRectify cv.initUndistortRectifyMap cv.remap
%