%GETBOARDOBJECTANDIMAGEPOINTS  Given a board configuration and a set of detected markers, returns the corresponding image points and object points to call solvePnP
%
%     [objPoints, imgPoints] = cv.getBoardObjectAndImagePoints(board, corners, ids)
%
% ## Input
% * __board__ Marker board layout.
% * __corners__ List of detected marker corners of the board.
% * __ids__ list of identifiers for each marker in `corners` (0-based).
%
% ## Output
% * __objPoints__ Cell array of board marker points in the board coordinate
%   space `{[x y z], ...}`
% * __imgPoints__ Cell array of the projections of board marker corner points
%   `{[x y], ...}`
%
% See also: cv.estimatePoseBoard, cv.solvePnP
%
