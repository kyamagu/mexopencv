%GOODFEATURESTOTRACK  Determines strong corners on an image
%
%    corners = cv.goodFeaturesToTrack(image)
%    corners = cv.goodFeaturesToTrack(image, 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ Input single-channel 8-bit or floating-point image.
%
% ## Output
% * __corners__ Output vector of detected corners.
%
% ## Options
% * __MaxCorners__ Maximum number of corners to return. If there are more
%         corners than are found, the strongest of them is returned. default 1000.
% * __QualityLevel__ Parameter characterizing the minimal accepted quality of
%         image corners. The parameter value is multiplied by the best corner
%         quality measure, which is the minimal eigenvalue (see
%         cv.cornerMinEigenVal ) or the Harris function response (see
%         cv.cornerHarris ). The corners with the quality measure less than the
%         product are rejected. For example, if the best corner has the quality
%         measure = 1500, and the qualityLevel=0.01 , then all the corners with
%         the quality measure less than 15 are rejected.
% * __MinDistance__ Minimum possible Euclidean distance between the returned
%         corners.
% * __Mask__ Optional region of interest. If the image is not empty (it needs
%         to have the type CV_8UC1 and the same size as image ), it specifies
%         the region in which the corners are detected.
% * __BlockSize__ Size of an average block for computing a derivative
%         covariation matrix over each pixel neighborhood. See
%         cv.cornerEigenValsAndVecs.
% * __UseHarrisDetector__ Parameter indicating whether to use a Harris detector
%         (see cv.cornerHarris ) or cv.cornerMinEigenVal
% * __K__ Harris detector free parameter.
%
% The function finds the most prominent corners in the image or in the specified
% image region, as described in [Shi94]:
%
%  1. Function calculates the corner quality measure at every source image pixel
%     using the cornerMinEigenVal() or cornerHarris().
%  2. Function performs a non-maximum suppression (the local maximums in 3 x 3
%     neighborhood are retained).
%  3. The corners with the minimal eigenvalue less than QualityLevel * max_{x,y}
%     (qualityMeasureMap(x,y)) are rejected.
%  4. The remaining corners are sorted by the quality measure in the descending
%     order.
%  5. Function throws away each corner for which there is a stronger corner at
%     a distance less than maxDistance.
%
% The function can be used to initialize a point-based tracker of an object.
%
% See also cv.cornerMinEigenVal cv.cornerHarris cv.FeatureDetector
%
