%DRAWCHARUCOBOARD  Draw a ChArUco board
%
%     img = cv.drawCharucoBoard(board, outSize)
%     img = cv.drawCharucoBoard(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __board__ ChArUco board that will be drawn.
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
% This function return the image of the ChArUco board, ready to be printed.
%
% See also: cv.estimatePoseCharucoBoard, cv.drawPlanarBoard, cv.drawMarkerAruco
%
