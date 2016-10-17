%CALIBRATECAMERAARUCO  Calibrate a camera using aruco markers
%
%    [cameraMatrix, distCoeffs, reprojErr] = cv.calibrateCameraAruco(corners, ids, counter, board, imageSize)
%    [cameraMatrix, distCoeffs, reprojErr, rvecs, tvecs] = cv.calibrateCameraAruco(...)
%    [...] = cv.calibrateCameraAruco(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __corners__ vector of detected marker corners in all frames. The corners
%       should have the same format returned by cv.detectMarkers
%       `{{[x,y],..}, ..}`.
% * __ids__ vector of identifiers for each marker in `corners` (0-based).
% * __counter__ number of markers in each frame so that `corners` and `ids`
%       can be split.
% * __board__ Marker board layout.
% * __imageSize__ Size of the image `[w,h]` used only to initialize the
%       intrinsic camera matrix.
%
% ## Output
% * __cameraMatrix__ Output 3x3 floating-point camera matrix
%       `A = [fx 0 cx; 0 fy cy; 0 0 1]`. If `UseIntrinsicGuess` and/or
%       `FixAspectRatio` are specified, some or all of `fx`, `fy`, `cx`, `cy`
%       must be initialized before calling the function.
% * __distCoeffs__ Output vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
% * __reprojErr__ the final re-projection error.
% * __rvecs__ Output cell-array of rotation vectors estimated for each board
%       view. That is, each k-th rotation vector together with the
%       corresponding k-th translation vector (see the next output parameter
%       description) brings the board pattern from the model coordinate space
%       (in which object points are specified) to the world coordinate space,
%       that is, a real position of the board pattern in the k-th pattern view
%       (`k=0..M-1`).
% * __tvecs__ Output cell-array of translation vectors estimated for each
%       pattern view.
%
% ## Options
% * __CameraMatrix__, __DistCoeffs__, __UseIntrinsicGuess__,
%   __FixPrincipalPoint__, __FixAspectRatio__, __ZeroTangentDist__,
%   __FixK1__, ..., __FixK6__, __RationalModel__, __ThinPrismModel__,
%   __FixS1S2S3S4__, __TiltedModel__, __FixTauXTauY__, __UseLU__
%       Different flags for the calibration process. See cv.calibrateCamera.
% * __Criteria__ Termination criteria for the iterative optimization algorithm.
%       default `struct('type','Count+EPS', 'maxCount',30, 'epsilon',eps)`
%
% This function calibrates a camera using an Aruco Board. The function
% receives a list of detected markers from several views of the board. The
% process is similar to the chessboard calibration in cv.calibrateCamera.
%
% See also: cv.detectMarkers, cv.calibrateCameraCharuco, cv.calibrateCamera,
%  cv.Rodrigues
%
