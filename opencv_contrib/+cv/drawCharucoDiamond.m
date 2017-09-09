%DRAWCHARUCODIAMOND  Draw a ChArUco Diamond marker
%
%     img = cv.drawCharucoDiamond(dictionary, ids, squareLength, markerLength)
%     img = cv.drawCharucoDiamond(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __dictionary__ dictionary of markers indicating the type of markers.
% * __ids__ vector of 4 ids for each ArUco marker in the ChArUco marker.
% * __squareLength__ size of the chessboard squares in pixels.
% * __markerLength__ size of the markers in pixels.
%
% ## Output
% * __img__ output image with the marker. The size of this image will be
%   `3*squareLength + 2*marginSize`.
%
% ## Options
% * __MarginSize__ minimum margins (in pixels) of the marker in the output
%   image. default 0
% * __BorderBits__ width of the marker borders. default 1
%
% This function return the image of a ChArUco marker, ready to be printed.
%
% See also: cv.detectCharucoDiamond, cv.drawCharucoBoard, cv.drawMarkerAruco
%
