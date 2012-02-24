%DISTANCETRANSFORM  Calculates the distance to the closest zero pixel for
% each pixel of the source image
%
%     dst = cv.distanceTransform(src)
%     dst = cv.distanceTransform(src, 'DistanceType', distanceType, ...)
%     [dst, labels] = cv.distanceTransform(...)
%
% ## Input
% * __src__ 8-bit, single-channel (binary) source image.
%
% ## Output
% * __dst__ Output image with calculated distances. It is a 32-bit
%        floating-point, single-channel image of the same size as src.
% * __labels__ Optional output 2D array of labels (the discrete Voronoi diagram).
%        It has the type int32 and the same size as src
%
% ## Options
% * __DistanceType__ Type of distance. It can be 'L1', 'L2' , or 'C'
% * __MaskSize__ Size of the distance transform mask. It can be 3, 5, or
%        'MaskPrecise' (the latter option is only supported by the
%        first function). In case of the 'L1' or 'C' distance type, the
%        parameter is forced to 3 because a 3 x 3 mask gives the same
%        result as 5 x 5 or any larger aperture.
%
% The functions distanceTransform calculate the approximate or precise distance
% from every binary image pixel to the nearest zero pixel. For zero image
% pixels, the distance will obviously be zero.
%
% When MaskSize is 'MaskPrecise' and DistanceType is 'L2', the
% function runs the algorithm described in [Felzenszwalb04].
%
% In other cases, the algorithm [Borgefors86] is used. This means that for a
% pixel the function finds the shortest path to the nearest zero pixel
% consisting of basic shifts: horizontal, vertical, diagonal, or knight's move
% (the latest is available for a  mask). The overall distance is calculated as
% a sum of these basic distances. Since the distance function should be
% symmetric, all of the horizontal and vertical shifts must have the same cost
% (denoted as a ), all the diagonal shifts must have the same cost (denoted as
% b ), and all knight's moves must have the same cost (denoted as c ). For the
% 'C' and 'L1' types, the distance is calculated precisely, whereas for 'L2'
% (Euclidian distance) the distance can be calculated only with a relative
% error (a 5 x 5 mask gives more accurate results). For a, b, and c,
% OpenCV uses the values suggested in the original paper:
%
%     'C'   3 x 3    a = 1,     b = 1
%     'L1'  3 x 3    a = 1,     b = 2
%     'L2'  3 x 3    a = 0.955, b = 1.3693
%     'L2'  5 x 5    a = 1,     b = 1.4,    c = 2.1969
%
% Typically, for a fast, coarse distance estimation 'L2', a 3 x 3 mask is
% used. For a more accurate distance estimation 'L2', a 5 x 5 mask or the
% precise algorithm is used. Note that both the precise and the approximate
% algorithms are linear on the number of pixels.
%
% The second variant of the function does not only compute the minimum distance
% for each pixel (x, y) but also identifies the nearest connected component
% consisting of zero pixels. Index of the component is stored in labels(x, y).
% The connected components of zero pixels are also found and marked by the
% function.
%
% In this mode, the complexity is still linear. That is, the function provides
% a very fast way to compute the Voronoi diagram for a binary image. Currently,
% the second variant can use only the approximate distance transform algorithm.
%
