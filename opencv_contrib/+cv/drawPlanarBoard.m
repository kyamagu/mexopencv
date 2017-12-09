%DRAWPLANARBOARD  Draw a planar board
%
%     img = cv.drawPlanarBoard(board, outSize)
%     img = cv.drawPlanarBoard(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __board__ layout of the board that will be drawn. The board should be
%   planar, z coordinate is ignored.
% * __outSize__ size of the output image in pixels `[w,h]`.
%
% ## Output
% * __img__ output image with the board. The size of this image will be
%   `outSize` and the board will be on the center, keeping the board
%   proportions.
%
% ## Options
% * __MarginSize__ minimum margins (in pixels) of the board in the output
%   image. default 0
% * __BorderBits__ width of the marker borders. default 1
%
% This function return the image of a planar board, ready to be printed. It
% assumes the board layout specified is planar by ignoring the z coordinates
% of the object points.
%
% See also: cv.estimatePoseBoard, cv.drawMarkerAruco, cv.drawCharucoBoard
%
