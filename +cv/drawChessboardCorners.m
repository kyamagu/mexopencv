%DRAWCHESSBOARDCORNERS  Renders the detected chessboard corners
%
%    im = cv.drawChessboardCorners(im, patternSize, corners)
%    im = cv.drawChessboardCorners(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Source image. It must be an 8-bit color image.
% * __patternSize__ Number of inner corners per a chessboard row and column
%        (`patternSize = [points_per_row, points_per_column]`).
% * __corners__ Array of detected corners, the output of
%        cv.findChessboardCorners.
%
% ## Output
% * __im__ Destination image.
%
% ## Options
% * __PatternWasFound__ Parameter indicating whether the complete board was
%       found or not. The return value of cv.findChessboardCorners should be
%       passed here. default true
%
% The function draws individual chessboard corners detected either as red
% circles if the board was not found, or as colored corners connected with
% lines if the board was found.
%
% See also: cv.findChessboardCorners, findCirclesGrid
%
