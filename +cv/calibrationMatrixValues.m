%CALIBRATIONMATRIXVALUES  Computes useful camera characteristics from the camera matrix
%
%    S = cv.calibrationMatrixValues(cameraMatrix, imageSize, apertureWidth, apertureHeight)
%
% ## Input
% * __cameraMatrix__ Input 3x3 camera matrix that can be estimated by
%       cv.calibrateCamera or cv.stereoCalibrate.
% * __imageSize__ Input image size `[w,h]` in pixels.
% * __apertureWidth__ Physical width in mm of the sensor.
% * __apertureHeight__ Physical height in mm of the sensor.
%
% ## Output
% * __S__ Struct with the following fields
%       * __fovx__ Output field of view in degrees along the horizontal sensor
%             axis.
%       * __fovy__ Output field of view in degrees along the vertical sensor
%             axis.
%       * __focalLength__ Focal length of the lens in mm.
%       * __principalPoint__ Principal point `[cx,cy]` in mm.
%       * __aspectRatio__ Pixel aspect ratio `fy/fx`.
%
% The function computes various useful camera characteristics from the
% previously estimated camera matrix.
%
% ## Note
% Do keep in mind that the unity measure 'mm' stands for whatever unit of
% measure one chooses for the chessboard pitch (it can thus be any value).
%
% See also: cv.calibrateCamera, cv.stereoCalibrate
%
