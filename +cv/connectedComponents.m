%CONNECTEDCOMPONENTS  Computes the connected components labeled image of boolean image
%
%    [labels,N] = cv.connectedComponents(image)
%    [labels,N,stats,centroids] = cv.connectedComponents(image)
%    [...] = cv.connectedComponents(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __image__ boolean image to be labeled, 1-channel 8-bit or logical matrix.
%
% ## Output
% * __labels__ output labeled image of same size as input `image` and
%       specified type in `LType`. Labels are in the range `[0, N-1]` where
%       0 represents the background label.
% * __N__ the total number of labels.
% * __stats__ (optional) statistics output for each label, including the
%       background label, see below for available statistics. A Nx5 integer
%       matrix. Statistics are accessed via `stats(label, col)` where:
%       * `col=1`: The leftmost (x) coordinate which is the inclusive start of
%             the bounding box in the horizontal direction.
%       * `col=2`: The topmost (y) coordinate which is the inclusive start of
%             the bounding box in the vertical direction.
%       * `col=3`: The horizontal size of the bounding box (width).
%       * `col=4`: The vertical size of the bounding box (height).
%       * `col=5`: The total area (in pixels) of the connected component.
% * __centroids__ (optional) floating point centroid `(x,y)` output for each
%       label, including the background label. A Nx2 numeric matrix.
%
% ## Options
% * __Connectivity__ 8 or 4 for 8-way or 4-way connectivity respectively.
%       default 8
% * __LType__ specifies the output image label type, an important consideration
%       based on the total number of labels or alternatively the total number
%       of pixels in the source image. Currently `int32` and `uint16` are
%       supported. default `int32`
%
% The last two optional output arguments are only computed if requested.
%
% See also: cv.findContours, bwconncomp, labelmatrix, regionprops
%
