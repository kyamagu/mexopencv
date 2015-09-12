%CALCBACKPROJECT  Calculates the back projection of a histogram
%
%    backProject = cv.calcBackProject(images, H, ranges)
%    backProject = cv.calcBackProject(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __images__ Source arrays. A numeric array, or cell array of numeric arrays
%       are accepted. They all should have the same class (`uint8`, `uint16`,
%       or `single`) and the same row/column size. Each of them can have an
%       arbitrary number of channels.
% * __H__ Input histogram that can be dense or sparse.
% * __ranges__ Cell-array of arrays of the histogram bin boundaries in each
%       dimension. See cv.calcHist.
%
% ## Output
% * __backProject__ Destination back projection array that is a single-channel
%       array of the same row/column size and depth as `images` (if numeric)
%       or `images{1}` (if `images` is a cell array). Out of `uint8`,
%       `uint16`, or `single` classes. Pay attention to the data type of the
%       back projection array, where integer types are clamped to the maximum
%       `intmax` if a value exceeds the largest possible integer of the type.
%
% ## Options
% * __Channels__ The list of channels used to compute the back projection (as
%       0-based indices). The number of channels must match the histogram
%       dimensionality. The first array channels are numerated from `0` to
%       `size(images{1},3)-1`, the second array channels are counted from
%       `size(images{1},3)` to `size(images{1},3) + size(images{2},3)-1`, and
%       so on. By default, all channels from all images are used, i.e default
%       is `0:sum(cellfun(@(im)size(im,3), images))-1` when input `images` is
%       a cell array, and `0:(size(images,3)-1)` when input `images` is a
%       numeric array.
% * __Uniform__ Logical flag indicating whether the histogram is uniform
%       or not (see above). default false.
% * __Scale__ Optional scale factor for the output back projection. default 1
%
% The function cv.calcBackProject calculates the back project of the
% histogram. That is, similarly to cv.calcHist, at each location (x, y) the
% function collects the values from the selected channels in the input images
% and finds the corresponding histogram bin. But instead of incrementing it,
% the function reads the bin value, scales it by scale, and stores in
% `backProject(x,y)`. In terms of statistics, the function computes
% probability of each element value in respect with the empirical probability
% distribution represented by the histogram. See how, for example, you can
% find and track a bright-colored object in a scene:
%
%  1. Before tracking, show the object to the camera so that it covers almost
%     the whole frame. Calculate a hue histogram. The histogram may have
%     strong maximums, corresponding to the dominant colors in the object.
%  2. When tracking, calculate a back projection of a hue plane of each input
%     video frame using that pre-computed histogram. Threshold the back
%     projection to suppress weak colors. It may also make sense to suppress
%     pixels with non-sufficient color saturation and too dark or too bright
%     pixels.
%  3. Find connected components in the resulting picture and choose, for
%     example, the largest component.
%
% This is an approximate algorithm of the cv.CamShift color object tracker.
%
% See also: cv.calcHist, cv.compareHist
%
