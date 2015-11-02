%GOODFEATURESTOTRACK  Determines strong corners on an image
%
%    corners = cv.goodFeaturesToTrack(image)
%    corners = cv.goodFeaturesToTrack(image, 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ Input 8-bit or floating-point 32-bit, single-channel image.
%
% ## Output
% * __corners__ Output vector of detected corners. A cell array of 2-elements
%       vectors `{[x,y], ...}`.
%
% ## Options
% * __MaxCorners__ Maximum number of corners to return. If there are more
%       corners than are found, the strongest of them is returned.
%       default 1000.
% * __QualityLevel__ Parameter characterizing the minimal accepted quality of
%       image corners. The parameter value is multiplied by the best corner
%       quality measure, which is the minimal eigenvalue (see
%       cv.cornerMinEigenVal) or the Harris function response (see
%       cv.cornerHarris). The corners with the quality measure less than the
%       product are rejected. For example, if the best corner has the quality
%       measure = 1500, and the `QualityLevel=0.01`, then all the corners with
%       the quality measure less than 15 are rejected. default 0.01
% * __MinDistance__ Minimum possible Euclidean distance between the returned
%       corners. default 2.0
% * __Mask__ Optional region of interest. If the image is not empty (it needs
%       to have the type `uint8`/`logical` and the same size as `image`), it
%       specifies the region in which the corners are detected. It is not set
%       by default.
% * __BlockSize__ Size of an average block for computing a derivative
%       covariation matrix over each pixel neighborhood. See
%       cv.cornerEigenValsAndVecs. default 3
% * __UseHarrisDetector__ Parameter indicating whether to use a Harris detector
%       (see cv.cornerHarris) or cv.cornerMinEigenVal, default false
% * __K__ Free parameter of the Harris detector. default 0.04
%
% The function finds the most prominent corners in the image or in the specified
% image region, as described in [Shi94]:
%
%  1. Function calculates the corner quality measure at every source image pixel
%     using the cv.cornerMinEigenVal or cv.cornerHarris.
%  2. Function performs a non-maximum suppression (the local maximums in `3x3`
%     neighborhood are retained).
%  3. The corners with the minimal eigenvalue less than
%     `QualityLevel * max_{x,y}(qualityMeasureMap(x,y))` are rejected.
%  4. The remaining corners are sorted by the quality measure in the descending
%     order.
%  5. Function throws away each corner for which there is a stronger corner at
%     a distance less than `maxDistance`.
%
% The function can be used to initialize a point-based tracker of an object.
%
% **NOTE**: If the function is called with different values `A` and `B` of the
% parameter `QualityLevel`, and `A > B`, the vector of returned corners with
% `QualityLevel=A` will be the prefix of the output vector with
% `QualityLevel=B`.
%
% ## References
% [Shi94]:
% > Jianbo Shi and Carlo Tomasi. Good features to track.
% > In Computer Vision and Pattern Recognition, 1994. Proceedings CVPR'94.,
% > 1994 IEEE Computer Society Conference on, pages 593-600. IEEE, 1994.
%
% See also: cv.GFTTDetector, cv.cornerMinEigenVal, cv.cornerHarris,
%   cv.calcOpticalFlowPyrLK, cv.estimateRigidTransform, corner
%
