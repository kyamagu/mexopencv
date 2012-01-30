%INITCAMERAMATRIX2D  Finds an initial camera matrix from 3D-2D point correspondences
%
%   cameraMatrix = cv.initCameraMatrix2D(objectPoints, imagePoints, imageSize)
%   [...] = cv.initCameraMatrix2D(..., 'OptionName', optionValue, ...)
%
% Input:
%    objectPoints: Vector of vectors of the calibration pattern points in
%        the calibration pattern coordinate space. Cell array of cell array
%        of 3-element vectors are accepted.
%    imagePoints: Vector of vectors of the projections of the calibration
%        pattern points. Cell array of cell array of 2-element vectors are
%        accepted.
%    imageSize: Image size in pixels used to initialize the principal
%        point.
% Output:
%    cameraMatrix: Camera matrix.
% Options:
%    'AspectRatio': If it is zero or negative, both fx and fy are estimated
%        independently. Otherwise, fx = fy * AspectRatio.
%
% The function estimates and returns an initial camera matrix for the
% camera calibration process. Currently, the function only supports planar
% calibration patterns, which are patterns where each object point has
% z-coordinate=0.
%
% See also cv.calibrateCamera
%