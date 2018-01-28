%SOLVEP3P  Finds an object pose from 3 3D-2D point correspondences
%
%     [rvecs, tvecs, solutions] = cv.solveP3P(objectPoints, imagePoints, cameraMatrix)
%     [...] = cv.solveP3P(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Array of object points in the object coordinate space,
%   1xNx3/Nx1x3 or Nx3 array, where `N=3` is the number of points, or cell
%   array of length `N=3` of 3-element vectors can be also passed here
%   `{[x1,y1,z1], [x2,y2,z2], [x3,y3,z3]}`.
% * __imagePoints__ Array of corresponding image points, 1xNx2/Nx1x2 or Nx2
%   array, where `N=3` is the number of points, or cell array of length `N=3`
%   of 2-element vectors can be also passed here `{[x1,y1], [x2,y2], [x3,y3]}`.
% * __cameraMatrix__ Input camera matrix `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
%
% ## Output
% * __rvecs__ Output rotation vectors (see cv.Rodrigues) that, together with
%   `tvecs`, brings points from the model coordinate system to the camera
%   coordinate system. A P3P problem has up to 4 solutions.
% * __tvecs__ Output translation vectors.
% * __solutions__ number of solutions.
%
% ## Options
% * __DistCoeffs__ Input vector of distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4,taux,tauy]` of 4, 5, 8, 12 or 14
%   elements. If the vector is empty, the zero distortion coefficients are
%   assumed. default empty.
% * __Method__ Method for solving the P3P problem. One of the following:
%   * __P3P__ (default) Method is based on the paper [gao2003complete].
%   * __AP3P__ Method is based on the paper [Ke17].
%
% The function estimates the object pose given 3 object points, their
% corresponding image projections, as well as the camera matrix and the
% distortion coefficients.
%
% ## References
% [gao2003complete]:
% > X.S. Gao, X.R. Hou, J. Tang, H.F. Chang; "Complete Solution
% > Classification for the Perspective-Three-Point Problem",
% > IEEE Trans. on PAMI, vol. 25, No. 8, p. 930-943, August 2003.
%
% [Ke17]:
% > T. Ke, S. Roumeliotis; "An Efficient Algebraic Solution to the
% > Perspective-Three-Point Problem", IEEE Conference on Computer Vision and
% > Pattern Recognition (CVPR), 2017
% > [PDF](https://arxiv.org/pdf/1701.08237.pdf)
%
% See also: cv.solvePnP
%
