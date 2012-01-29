%CALIBRATIONMATRIXVALUES  Computes useful camera characteristics from the camera matrix
%
%   S = cv.calibrationMatrixValues(cameraMatrix, imageSize, apertureWidth, apertureHeight)
%
% Input:
%    cameraMatrix: Input camera matrix that can be estimated by
%        cv.calibrateCamera or cv.stereoCalibrate.
%    imageSize: Input image size [w,h] in pixels.
%    apertureWidth: Physical width of the sensor.
%    apertureHeight: Physical height of the sensor.
% Output:
%    S: Struct with the following fields
%        fovx: Output field of view in degrees along the horizontal sensor axis.
%        fovy: Output field of view in degrees along the vertical sensor axis.
%        focalLength: Focal length of the lens in mm.
%        principalPoint: Principal point in pixels.
%        aspectRatio: fy/fx.
%
% The function computes various useful camera characteristics from the
% previously estimated camera matrix.
%
% See also cv.calibrateCamera cv.stereoCalibrate
%