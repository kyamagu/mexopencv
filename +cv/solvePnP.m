%SOLVEPNP  Finds an object pose from 3D-2D point correspondences
%
%   [rvec, tvec] = cv.solvePnP(objectPoints, imagePoints, cameraMatrix)
%   [rvec, tvec] = cv.solvePnP(objectPoints, imagePoints, cameraMatrix, distCoeffs)
%   [...] = cv.solvePnP(..., distCoeffs, 'OptionName', optionValue, ...)
%
% Input:
%    objectPoints: Array of object points in the object coordinate space,
%        1xNx3/Nx1x3 array, where N is the number of points, or cell array
%        of 3-element vectors can be also passed here.
%    imagePoints: Array of corresponding image points, 1xNx2/Nx1x2 array,
%         where N is the number of points, or cell array of 2-element
%         vectors can be also passed here.
%    cameraMatrix: Input camera matrix A = [fx,0,cx;0,fy,cy;0,0,1].
%    distCoeffs: Input vector of distortion coefficients [k1,k2,p1,p2,k3,
%        k4,k5,k6] of 4, 5, or 8 elements. If the vector is NULL/empty, the
%        zero distortion coefficients are assumed.
% Output:
%    rvec: Output rotation vector (see cv.Rodrigues) that, together with
%        tvec , brings points from the model coordinate system to the
%        camera coordinate system.
%    tvec: Output translation vector.
% Options:
%    'Rvec': Initial rvec.
%    'Tvec': Initial tvec.
%    'UseExtrinsicGuess': If true (1), the function uses the provided rvec
%        and tvec values as initial approximations of the rotation and
%        translation vectors, respectively, and further optimizes them.
%        default false.
%
% The function estimates the object pose given a set of object points,
% their corresponding image projections, as well as the camera matrix and
% the distortion coefficients. This function finds such a pose that
% minimizes reprojection error, that is, the sum of squared distances
% between the observed projections imagePoints and the projected (using
% cv.projectPoints) objectPoints .
%
% See also cv.solvePnPRansac
%