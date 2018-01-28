%RECOVERPOSE  Recover relative camera rotation and translation from an estimated essential matrix and the corresponding points in two images, using cheirality check
%
%     [R, t, good] = cv.recoverPose(E, points1, points2)
%     [R, t, good, mask, triangulatedPoints] = cv.recoverPose(...)
%     [...] = cv.recoverPose(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __E__ The input essential matrix, 3x3.
% * __points1__ Cell array of N 2D points from the first image, or numeric
%   array Nx2/Nx1x2/1xNx2. The point coordinates should be floating-point
%   (single or double precision).
% * __points2__ Cell array or numeric array of the second image points of the
%   same size and format as `points1`.
%
% ## Output
% * __R__ Recovered relative rotation, 3x3 matrix.
% * __t__ Recovered relative translation, 3x1 vector.
% * __good__ the number of inliers which pass the cheirality check.
% * __mask__ Output mask for inliers in `points1` and `points2`. In the output
%   mask only inliers which pass the cheirality check. Vector of length N, see
%   the `Mask` input option.
% * __triangulatedPoints__ 3D points which were reconstructed by triangulation,
%   see cv.triangulatePoints
%
% ## Options
% * __CameraMatrix__ Camera matrix `K = [fx 0 cx; 0 fy cy; 0 0 1]`. Note that
%   this function assumes that `points1` and `points2` are feature points from
%   cameras with the same camera matrix. default `eye(3)`.
% * __DistanceThreshold__ threshold distance which is used to filter out far
%   away points (i.e. infinite points). default 50.0
% * __Mask__ Input mask of length N for inliers in `points1` and `points2`
%   (0 for outliers and to 1 for the other points (inliers). If it is not
%   empty, then it marks inliers in `points1` and `points2` for then given
%   essential matrix `E`. Only these inliers will be used to recover pose.
%   Not set by default.
%
% This function decomposes an essential matrix using cv.decomposeEssentialMat
% and then verifies possible pose hypotheses by doing cheirality check. The
% cheirality check basically means that the triangulated 3D points should have
% positive depth. Some details can be found in [Nister03].
%
% This function can be used to process output `E` and `mask` from
% cv.findEssentialMat. In this scenario, `points1` and `points2` are the same
% input for cv.findEssentialMat.
%
% ## Example
%
%     % Estimation of fundamental matrix using the RANSAC algorithm
%     point_count = 100;
%     points1 = cell(1, point_count);
%     points2 = cell(1, point_count);
%     % initialize the points here ...
%     for i=1:point_count
%         points1{i} = ...;  % [x,y]
%         points2{i} = ...;  % [x,y]
%     end
%
%     % cametra matrix with both focal lengths = 1, and principal point = [0 0]
%     cameraMatrix = eye(3,3);
%
%     [E, mask] = cv.findEssentialMat(points1, points2, ...
%         'CameraMatrix',cameraMatrix, 'Method','Ransac');
%     [R, t, ~, mask] = cv.recoverPose(E, points1, points2, ...
%         'CameraMatrix',cameraMatrix, 'Mask',mask);
%
% ## References
% [Nister03]:
% > David Nister. "An efficient solution to the five-point relative pose
% > problem". Pattern Analysis and Machine Intelligence, IEEE Transactions on,
% > 26(6):756-770, 2004.
%
% See also: cv.findEssentialMat, cv.decomposeEssentialMat,
%  cv.triangulatePoints, relativeCameraPose
%
