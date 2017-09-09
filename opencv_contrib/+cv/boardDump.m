%BOARDDUMP  Dump board (aruco)
%
%     s = cv.boardDump(board)
%
% ## Input
% * __board__ layout of markers in the board.
%
% ## Output
% * __s__ Output struct with the following fields:
%   * __objPoints__ array of object points of all the marker corners in the
%     board.
%   * __dictionary__ the dictionary of markers employed for this board.
%   * __ids__ vector of the identifiers of the markers in the board.
%
% See also: cv.estimatePoseBoard, cv.dictionaryDump
%
