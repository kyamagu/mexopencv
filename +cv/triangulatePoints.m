%TRIANGULATEPOINTS  Reconstructs points by triangulation
%
%    points4D = cv.triangulatePoints(projMatr1, projMatr2, projPoints1, projPoints2)
%
% ## Input
% * __projMatr1__ 3x4 projection matrix of the first camera.
% * __projMatr2__ 3x4 projection matrix of the second camera.
% * __projPoints1__ 2xN array of feature points in the first image. It can be
%       also a cell array of feature points `{[x,y], ...}` or two-channel
%       array of size 1xNx2 or Nx1x2.
% * __projPoints2__ 2xN array of corresponding points in the second image. It
%       can be also a cell array of feature points `{[x,y], ...}` or
%       two-channel array of size 1xNx2 or Nx1x2.
%
% ## Output
% * __points4D__ 4xN array of reconstructed points in homogeneous coordinates
%       `[[x;y;z;w], ...]`
%
% The function reconstructs 3-dimensional points (in homogeneous coordinates)
% by using their observations with a stereo camera. Projections matrices can
% be obtained from cv.stereoRectify.
%
% ## Note
% Keep in mind that all input data should be of float type in order for
% this function to work (`single` or `double`).
%
% See also: cv.reprojectImageTo3D
%
