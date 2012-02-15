%FINDCIRCLESGRID  Finds the centers in the grid of circles
%
%    centers = cv.findCirclesGrid(im, patternSize)
%    [...] = cv.findCirclesGrid(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Grid view of source circles. It must be an 8-bit grayscale or
%        color image.
% * __patternSize__ Number of circles per a grid row and column
%        (`patternSize = [points_per_row, points_per_colum]`).
%
% ## Output
% * __centers__ Array of detected centers.
%
% ## Options
% * __SymmetricGrid__ Use symmetric pattern of circles. default true.
% * __Clustering__ Use a special algorithm for grid detection. It is more
%        robust to perspective distortions but much more sensitive to
%        background clutter. default false.
%
% The function attempts to determine whether the input image contains a
% grid of circles. If it is, the function locates centers of the circles.
% The function returns a non-empty value if all of the centers have been
% found and they have been placed in a certain order (row by row, left to
% right in every row). Otherwise, if the function fails to find all the
% corners or reorder them, it returns empty array.
%
% ## Note
% The function requires white space (like a square-thick border,
% the wider the better) around the board to make the detection more robust
% in various environments.
%
% See also cv.findChessboardCorners
%
