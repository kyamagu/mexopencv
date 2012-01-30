%DRAWCHESSBOARDCORNERS  Finds the positions of internal corners of the chessboard
%
%   im = cv.drawChessboardCorners(im, patternSize, corners)
%
% Input:
%    im: Source image. It must be an 8-bit color image.
%    patternSize: Number of inner corners per a chessboard row and column
%        (patternSize = [points_per_row,points_per_column]).
%    corners: Array of detected corners, the output of
%        cv.findChessboardCorners.
% Output:
%    im: Destination image.
%
% The function draws individual chessboard corners detected either as red
% circles if the board was not found, or as colored corners connected with
% lines if the board was found.
%
% See also cv.findChessboardCorners
%