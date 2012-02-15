%CALCBACKPROJECT  Calculates the back projection of a histogram
%
%    Y = cv.calcBackProject(X, H, edges)
%
% ## Input
% * __X__ Source pixel arrays. A numeric array, or cell array of numeric
%       arrays are accepted. They all should have the same class and the
%       same size.
% * __H__ Input histogram that can be dense or sparse.
%
% ## Output
% * __Y__ Destination back projection array that is a single-channel array of
%       the same size as X or the first element of X if X is a cell array.
%
% ## Options
% * __Uniform__ Logical flag indicating whether the histogram is uniform
%       or not. default false.
% * __Scale__ Optional scale factor for the output back projection. default
%       1.
%
% The functions calcBackProject calculate the back project of the
% histogram. That is, similarly to calcHist , at each location (x, y) the
% function collects the values from the selected channels in the input
% images and finds the corresponding histogram bin. But instead of
% incrementing it, the function reads the bin value, scales it by scale,
% and stores in backProject(x,y) . In terms of statistics, the function
% computes probability of each element value in respect with the empirical
% probability distribution represented by the histogram. See how, for
% example, you can find and track a bright-colored object in a scene:
%
%  1. Before tracking, show the object to the camera so that it covers
%     almost the whole frame. Calculate a hue histogram. The histogram may
%     have strong maximums, corresponding to the dominant colors in the
%     object.
%  2. When tracking, calculate a back projection of a hue plane of each
%     input video frame using that pre-computed histogram. Threshold the
%     back projection to suppress weak colors. It may also make sense to
%     suppress pixels with non-sufficient color saturation and too dark or
%     too bright pixels.
%  3. Find connected components in the resulting picture and choose, for
%     example, the largest component.
%
% This is an approximate algorithm of the CamShift() color object tracker.
%
% See also cv.calcHist
%
