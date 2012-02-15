%FINDCHESSBOARDCORNERS  Finds the positions of internal corners of the chessboard
%
%    corners = cv.findChessboardCorners(im, patternSize)
%    [...] = cv.findChessboardCorners(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Source chessboard view. It must be an 8-bit grayscale or color image.
% * __patternSize__ Number of inner corners per a chessboard row and column
%        (`patternSize = [points_per_row,points_per_colum] = [columns,rows]`).
%
% ## Output
% * __corners__ Output array of detected corners.
%
% ## Options
% * __AdaptiveThresh__ Use adaptive thresholding to convert the image to black
%        and white, rather than a fixed threshold level (computed from the
%        average image brightness). default true.
% * __NormalizeImage__ Normalize the image gamma with cv.equalizeHist before
%        applying fixed or adaptive thresholding. default true.
% * __FilterQuads__ Use additional criteria (like contour area, perimeter,
%        square-like shape) to filter out false quads extracted at the contour
%        retrieval stage. default false.
% * __FastCheck__ Run a fast check on the image that looks for chessboard
%        corners, and shortcut the call if none is found. This can drastically
%        speed up the call in the degenerate condition when no chessboard is
%        observed. default false.
%
% The function attempts to determine whether the input image is a view of the
% chessboard pattern and locate the internal chessboard corners. The function
% returns a non-zero value if all of the corners are found and they are placed
% in a certain order (row by row, left to right in every row). Otherwise, if the
% function fails to find all the corners or reorder them, it returns 0. For
% example, a regular chessboard has 8 x 8 squares and 7 x 7 internal corners,
% that is, points where the black squares touch each other. The detected
% coordinates are approximate, and to determine their positions more accurately,
% the function calls cv.cornerSubPix. You also may use the function
% cv.cornerSubPix with different parameters if returned coordinates are not
% accurate enough.
%
% ## Note
% The function requires white space (like a square-thick border, the wider the
% better) around the board to make the detection more robust in various
% environments. Otherwise, if there is no border and the background is dark,
% the outer black squares cannot be segmented properly and so the square
% grouping and ordering algorithm fails.
%
% See also cv.drawChessboardCorners cv.calibrateCamera
%
