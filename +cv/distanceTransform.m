%DISTANCETRANSFORM  Calculates the distance to the closest zero pixel for each pixel of the source image
%
%     dst = cv.distanceTransform(src)
%     [dst, labels] = cv.distanceTransform(src)
%     [...] = cv.distanceTransform(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ 8-bit, single-channel (binary) source image.
%
% ## Output
% * __dst__ Output image with calculated distances. It is a 32-bit
%       floating-point, single-channel image of the same size as `src`.
% * __labels__ Optional output 2D array of labels (the discrete Voronoi
%       diagram). It has the type `int32` and the same size as `src`.
%
% ## Options
% * __DistanceType__ Type of distance, default 'L2'. One of:
%       * __L1__ `distance = |x1-x2| + |y1-y2|`
%       * __L2__ the simple euclidean distance
%       * __C__ `distance = max(|x1-x2|,|y1-y2|)`
% * __MaskSize__ Size of the distance transform mask. The 'Precise' option is
%       not supported by the second variant with `labels` output. In case of
%       the 'L1' or 'C' distance type, the parameter is forced to 3 because a
%       3x3 mask gives the same result as 5x5 or any larger aperture. The
%       following options are available:
%       * __3__ approximate distance transform with 3x3 mask (default)
%       * __5__ approximate distance transform with 5x5 mask
%       * __Precise__ precise distance transform
%
% The function cv.distanceTransform calculates the approximate or precise
% distance from every binary image pixel to the nearest zero pixel. For zero
% image pixels, the distance will obviously be zero.
%
% When `MaskSize` is 'Precise' and `DistanceType` is 'L2', the function
% runs the algorithm described in [Felzenszwalb04]. This algorithm is
% parallelized with the TBB library.
%
% In other cases, the algorithm [Borgefors86] is used. This means that for a
% pixel the function finds the shortest path to the nearest zero pixel
% consisting of basic shifts: horizontal, vertical, diagonal, or knight's move
% (the latest is available for a 5x5 mask). The overall distance is calculated
% as a sum of these basic distances. Since the distance function should be
% symmetric, all of the horizontal and vertical shifts must have the same cost
% (denoted as `a`), all the diagonal shifts must have the same cost (denoted
% as `b`), and all knight's moves must have the same cost (denoted as `c`).
% For the 'C' and 'L1' types, the distance is calculated precisely, whereas
% for 'L2' (Euclidian distance) the distance can be calculated only with a
% relative error (a 5x5 mask gives more accurate results). For `a`, `b`, and
% `c`, OpenCV uses the values suggested in the original paper:
%
% * __L1__
%       * 3x3: `a = 1,     b = 2`
% * __L2__
%       * 3x3: `a = 0.955, b = 1.3693`
%       * 5x5: `a = 1,     b = 1.4,    c = 2.1969`
% * __C__
%       * 3x3: `a = 1,     b = 1`
%
% Typically, for a fast, coarse distance estimation 'L2', a 3x3 mask is used.
% For a more accurate distance estimation 'L2', a 5x5 mask or the precise
% algorithm is used. Note that both the precise and the approximate
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
% the second variant can use only the approximate distance transform algorithm,
% i.e. `MaskSize='Precise'` is not supported yet.
%
% ## References
% [Felzenszwalb04]:
% > Pedro Felzenszwalb and Daniel Huttenlocher.
% > "Distance transforms of sampled functions".
% > Technical report, Cornell University, 2004.
%
% [Borgefors86]:
% > Gunilla Borgefors. "Distance transformations in digital images".
% > Computer vision, graphics, and image processing, 34(3):344-371, 1986.
%
% See also: bwdist
%
