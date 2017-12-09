%COMPUTECORRESPONDEPILINES  For points in an image of a stereo pair, computes the corresponding epilines in the other image
%
%     lines = cv.computeCorrespondEpilines(points, F)
%     [...] = cv.computeCorrespondEpilines(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __points__ Input points. Nx2/Nx1x2/1xNx2 floating-point array, or cell
%   array of length N of 2-element vectors `{[x,y], ...}`.
% * __F__ 3x3 Fundamental matrix that can be estimated using
%   cv.findFundamentalMat or cv.stereoRectify.
%
% ## Output
% * __lines__ Output vector of the epipolar lines corresponding to the points
%   in the other image. Each line `ax + by + c = 0` is encoded by 3 numbers
%   `(a,b,c)`. Nx3/Nx1x3 numeric matrix or a cell-array of 3-element vectors
%   `{[a,b,c], ...}` depending on `points` format.
%
% ## Options
% * __WhichImage__ Index of the image (1 or 2) that contains the points.
%   default 1.
%
% For every point in one of the two images of a stereo pair, the function
% finds the equation of the corresponding epipolar line in the other image.
%
% From the fundamental matrix definition (see cv.findFundamentalMat), line
% `lines2{i}` in the second image for the point `points1{i}` in the first image
% (when `WhichImage=1`) is computed as:
%
%     lines2{i} = F * points1{i}
%
% And vice versa, when `WhichImage=2`, `lines1{i}` is computed from
% `points2{i}` as:
%
%     lines1{i} = F^T * points2{i}
%
% Line coefficients are defined up to a scale. They are normalized so that
% `a_i^2 + b_i^2 = 1`.
%
% See also: cv.findFundamentalMat, cv.stereoRectify, epipolarLine
%
