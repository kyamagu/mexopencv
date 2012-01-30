%FILTERSPECKLES  Filters off small noise blobs (speckles) in the disparity map
%
%   im = cv.filterSpeckles(im, newVal, maxSpeckleSize, maxDiff)
%
% Input:
%    im: The input 16-bit signed disparity image.
%    newVal: The disparity value used to paint-off the speckles
%    maxSpeckleSize: The maximum speckle size to consider it a speckle.
%        Larger blobs are not affected by the algorithm
%    maxDiff: Maximum difference between neighbor disparity pixels to put
%        them into the same blob. Note that since StereoBM, StereoSGBM and
%        may be other algorithms return a fixed-point disparity map, where
%        disparity values are multiplied by 16, this scale factor should be
%        taken into account when specifying this parameter value.
% Output:
%    im: Filtered disparity image.
%
% See also cv.StereoBM cv.StereoSGBM
%