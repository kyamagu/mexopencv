%FINDCIRCLESGRID  Finds the centers in the grid of circles
%
%    centers = cv.findCirclesGrid(im, patternSize)
%    [centers,patternFound] = cv.findCirclesGrid(im, patternSize)
%    [...] = cv.findCirclesGrid(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Grid view of input circles. It must be an 8-bit grayscale or color
%       image.
% * __patternSize__ Number of circles per row and column
%       (`patternSize = [points_per_row, points_per_colum]`).
%
% ## Output
% * __centers__ Cell array of detected centers `{[x,y], ...}`.
% * __patternFound__ logical return value, see below.
%
% ## Options
% * __SymmetricGrid__ Use symmetric or asymmetric pattern of circles.
%       default true.
% * __Clustering__ Use a special algorithm for grid detection. It is more
%       robust to perspective distortions but much more sensitive to
%       background clutter. default false.
% * __BlobDetector__ feature detector that finds blobs like dark circles on
%       light background. It can be specified as a string containing the type
%       of feature detector, such as 'SimpleBlobDetector'. It can also be
%       specified as a cell-array of the form `{fdetector, 'key',val, ...}`,
%       where the first element is the type, and the remaining elements are
%       optional parameters used to construct the specified feature detector.
%       See cv.FeatureDetector for possible types.
%       default is to use cv.SimpleBlobDetector with its default parameters.
%
% The function attempts to determine whether the input image contains a grid
% of circles. If it is, the function locates centers of the circles. The
% function returns `true` if all of the centers have been found and they have
% been placed in a certain order (row by row, left to right in every row).
% Otherwise, if the function fails to find all the corners or reorder them,
% it returns `false`.
%
% ## Example
% Sample usage of detecting and drawing the centers of circles:
%
%    patternSize = [7,7];   % number of centers
%    gray = imread('...');  % source 8-bit image
%    [centers,patternfound] = cv.findCirclesGrid(gray, patternSize);
%    img = cv.drawChessboardCorners(img, patternSize, cat(1,centers{:}), ...
%        'PatternWasFound',patternfound);
%    imshow(img)
%
% ## Note
% The function requires white space (like a square-thick border, the wider the
% better) around the board to make the detection more robust in various
% environments.
%
% See also: cv.findChessboardCorners
%
