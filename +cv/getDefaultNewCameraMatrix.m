%GETDEFAULTNEWCAMERAMATRIX  Returns the default new camera matrix
%
%    newCameraMatrix = cv.getDefaultNewCameraMatrix(cameraMatrix)
%    [...] = cv.getDefaultNewCameraMatrix(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __cameraMatrix__ Input camera matrix, a 3x3 double matrix.
%
% ## Output
% * __newCameraMatrix__ Output camera matrix, same size and type as input.
%
% ## Options
% * __ImgSize__ Camera view image size in pixels `[w,h]`. Default [0,0]
% * __CenterPrincipalPoint__ Location of the principal point in the new camera
%       matrix. The parameter indicates whether this location should be at the
%       image center or not. default false
%
% The function returns the camera matrix that is either an exact copy of the
% input `cameraMatrix` (when `CenterPrinicipalPoint=false`), or the modified
% one (when `CenterPrincipalPoint=true`).
%
% In the latter case, the new camera matrix will be:
%
%    [ fx,   0,  (ImgSize(1)-1)*0.5 ;
%       0,  fy,  (ImgSize(2)-1)*0.5 ;
%       0,   0,                   1 ]
%
% where `fx` and `fy` are (0,0) and (1,1) elements of `cameraMatrix`,
% respectively.
%
% By default, the undistortion functions in OpenCV (see cv.undistort,
% cv.initUndistortRectifyMap) do not move the principal point. However, when
% you work with stereo, it is important to move the principal points in both
% views to the same y-coordinate (which is required by most of stereo
% correspondence algorithms), and may be to the same x-coordinate too. So, you
% can form the new camera matrix for each view where the principal points are
% located at the center.
%
