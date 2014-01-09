%SOLVEPNPRANSAC  Finds an object pose from 3D-2D point correspondences using the RANSAC scheme
%
%    [...] = cv.solvePnPRansac(objectPoints, imagePoints, cameraMatrix)
%    [...] = cv.solvePnPRansac(objectPoints, imagePoints, cameraMatrix, distCoeffs)
%    [...] = cv.solvePnPRansac(..., distCoeffs, 'OptionName', optionValue, ...)
%    [rvec, tvec, inliers] = cv.solvePnPRansac(...)
%
% ## Input
% * __objectPoints__ Array of object points in the object coordinate space,
%        1xNx3/Nx1x3 or 3xN/Nx3 array, where N is the number of points, or
%        cell array of 3-element vectors can be also passed here.
% * __imagePoints__ Array of corresponding image points, 1xNx2/Nx1x2 or
%        2xN/Nx2 array, where N is the number of points, or cell array of
%        2-element vectors can be also passed here.
% * __cameraMatrix__ Input camera matrix `A = [fx,0,cx; 0,fy,cy; 0,0,1]`.
% * __distCoeffs__ Input vector of distortion coefficients [k1,k2,p1,p2,k3,
%        k4,k5,k6] of 4, 5, or 8 elements. If the vector is empty, the
%        zero distortion coefficients are assumed.
%
% ## Output
% * __rvec__ Output rotation vector (see cv.Rodrigues) that, together with
%        `tvec`, brings points from the model coordinate system to the
%        camera coordinate system.
% * __tvec__ Output translation vector.
% * __inliers__ vector that contains indices of inliers in `objectPoints` and
%        `imagePoints`.
%
% ## Options
% * __Rvec__ Initial rvec. default empty.
% * __Tvec__ Initial tvec. default empty.
% * __UseExtrinsicGuess__ If true, the function uses the provided `rvec`
%        and `tvec` values as initial approximations of the rotation and
%        translation vectors, respectively, and further optimizes them.
%        default false.
% * __IterationsCount__ Number of iterations. default 100.
% * __ReprojectionError__ Inlier threshold value used by the RANSAC
%        procedure. The parameter value is the maximum allowed distance
%        between the observed and computed point projections to consider
%        it an inlier. default 8.0.
% * __MinInliersCount__ Number of inliers. If the algorithm at some stage
%        finds more inliers than `minInliersCount`, it finishes. default 100.
% * __Flags__ Method for solving a PnP problem. See cv.solvePnP.
%
% The function estimates an object pose given a set of object points, their
% corresponding image projections, as well as the camera matrix and the
% distortion coefficients. This function finds such a pose that minimizes
% reprojection error, that is, the sum of squared distances between the
% observed projections `imagePoints` and the projected (using
% cv.projectPoints) `objectPoints`. The use of RANSAC makes the function
% resistant to outliers.
%
% See also cv.solvePnP
%
