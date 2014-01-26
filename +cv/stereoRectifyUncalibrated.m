%STEREORECTIFYUNCALIBRATED  Computes a rectification transform for an uncalibrated stereo camera
%
%    [H1,H2] = cv.stereoRectifyUncalibrated(points1, points2, F, imgSize)
%    [...] = cv.stereoRectifyUncalibrated(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __points1__ The feature points in the first image as a cell array of
%               two-element vectors: {[x1, y1], [x2, y2], ...} or an
%               1-by-N-by-2 numeric array.
% * __points2__ The corresponding points in the second image as a cell array
%               of two-element vectors: {[x1, y1], [x2, y2], ...} or an
%               1-by-N-by-2 numeric array.
% * __F__ Input fundamental matrix. It can be computed from the same set of
%         point pairs using cv.findFundamentalMat.
% * __imageSize__ Size of the image.
%
% ## Output
% * __H1__ 3x3 rectification homography matrix for the first image.
% * __H2__ 3x3 rectification homography matrix for the second image.
%
% ## Options
% * __Threshold__ Optional threshold used to filter out the outliers. If
%     the parameter is greater than zero, all the point pairs that do
%     not comply with the epipolar geometry (that is, the points for
%     which `points2{i} * F * points1{i}' > Threshold`) are rejected
%     prior to computing the homographies. Otherwise,all the points are
%     considered inliers. default 5
%
% The function computes the rectification transformations without knowing
% intrinsic parameters of the cameras and their relative position in the
% space, which explains the suffix "uncalibrated". Another related
% difference from cv.stereoRectify is that the function outputs not the
% rectification transformations in the object (3D) space, but the planar
% perspective transformations encoded by the homography matrices H1 and H2.
% The function implements the algorithm [Hartley99].
%
% ## Note
% While the algorithm does not need to know the intrinsic parameters
% of the cameras, it heavily depends on the epipolar geometry. Therefore,
% if the camera lenses have a significant distortion, it would be better to
% correct it before computing the fundamental matrix and calling this
% function. For example, distortion coefficients can be estimated for each
% head of stereo camera separately by using cv.calibrateCamera. Then, the
% images can be corrected using cv.undistort, or just the point coordinates
% can be corrected with cv.undistortPoints.
%
% See also cv.stereoCalibrate cv.stereoRectify cv.calibrateCamera
% cv.undistort cv.undistortPoints
%
