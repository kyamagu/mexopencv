%COMPUTECORRESPONDEPILINES  For points in an image of a stereo pair, computes the corresponding epilines in the other image
%
%    lines = cv.computeCorrespondEpilines(points, F)
%    [...] = cv.computeCorrespondEpilines(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __points__ Input points. Nx2/Nx1x2/1xNx2 floating-point array, or cell
%       array of 2-element vectors `{[x,y], ...}`.
% * __F__ 3x3 Fundamental matrix that can be estimated using
%       cv.findFundamentalMat or cv.stereoRectify.
%
% ## Output
% * __lines__ Output vector of the epipolar lines corresponding to the points
%       in the other image. Each line `ax + by + c = 0` is encoded by 3
%       numbers `(a,b,c)`. Nx3/Nx1x3 numeric matrix or a cell-array of
%       3-element vectors `{[a,b,c], ...}` depending on `points` format.
%
% ## Options
% * __WhichImage__ Index of the image (1 or 2) that contains the points.
%       default 1.
%
% For every point in one of the two images of a stereo pair, the function
% finds the equation of the corresponding epipolar line in the other image.
%
% From the fundamental matrix definition (see cv.findFundamentalMat), line
% `l_i^(2)` in the second image for the point `p_i^(1)` in the first image
% (when `WhichImage=1`) is computed as:
%
%    l_i^(2) = F * p_i^(1)
%
% And vice versa, when `WhichImage=2`, `l_i^(1)` is computed from `p_i^(2)`
% as:
%
%    l_i^(1) = F^T * p_i^(2)
%
% Line coefficients are defined up to a scale. They are normalized so that
% `a_i^2 + b_i^2 = 1`.
%
% See also: cv.findFundamentalMat, cv.stereoRectify, epipolarLine
%
