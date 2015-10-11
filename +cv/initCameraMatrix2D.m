%INITCAMERAMATRIX2D  Finds an initial camera matrix from 3D-2D point correspondences
%
%    cameraMatrix = cv.initCameraMatrix2D(objectPoints, imagePoints, imageSize)
%    [...] = cv.initCameraMatrix2D(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Vector of vectors of the calibration pattern points in
%       the calibration pattern coordinate space. Cell array of cell array
%       of 3-element vectors are accepted `{{[x,y,z],...}, ...}`.
% * __imagePoints__ Vector of vectors of the projections of the calibration
%       pattern points. Cell array of cell array of 2-element vectors are
%       accepted `{{[x,y],...}, ...}`.
% * __imageSize__ Image size in pixels used to initialize the principal
%       point `[w,h]`.
%
% ## Output
% * __cameraMatrix__ Camera matrix 3x3, `A = [fx 0 cx; 0 fy cy; 0 0 1]`
%
% ## Options
% * __AspectRatio__ If it is zero or negative, both `fx` and `fy` are
%       estimated independently. Otherwise, `fx = fy * AspectRatio`.
%       default 1.0
%
% The function estimates and returns an initial camera matrix for the
% camera calibration process. Currently, the function only supports planar
% calibration patterns, which are patterns where each object point has
% z-coordinate=0.
%
% See also: cv.calibrateCamera
%
