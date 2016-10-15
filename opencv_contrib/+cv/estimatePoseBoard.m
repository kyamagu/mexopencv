%ESTIMATEPOSEBOARD  Pose estimation for a board of markers
%
%    [rvec, tvec, num] = cv.estimatePoseBoard(corners, ids, board, cameraMatrix, distCoeffs)
%
% ## Input
% * __corners__ cell array of already detected markers corners. For each
%       marker, its four corners are provided, (e.g `{{[x,y],..}, ..}`). The
%       order of the corners should be clockwise.
% * __ids__ list of identifiers for each marker in `corners` (0-based).
% * __board__ layout of markers in the board. The layout is composed by the
%       marker identifiers and the positions of each marker corner in the
%       board reference system.
%       You can specify the board as a cell-array that starts with the
%       type name followed by option arguments `{Type, ...}`.
%       There are three types of boards available:
%       * __Board__ `{'Board', objPoints, dictionary, ids}`.
%             Creates a board of markers.
%       * __GridBoard__ `{'GridBoard', markersX, markersY, markerLength, markerSeparation, dictionary}`.
%             Creates a a GridBoard object given the number of markers in each
%             direction and the marker size and marker separation.
%       * __CharucoBoard__ `{'GridBoard', squaresX, squaresY, squareLength, markerLength, dictionary}`.
%             Creates a CharucoBoard object given the number of squares in
%             each direction and the size of the markers and chessboard
%             squares.
% * __cameraMatrix__ input 3x3 floating-point camera matrix
%       `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __distCoeffs__ vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
%
% ## Output
% * __rvec__ Output vector `[x,y,z]` corresponding to the rotation vector of
%       the board.
% * __tvec__ Output vector `[x,y,z]` corresponding to the translation vector
%       of the board.
% * __num__ The number of markers from the input employed for the board pose
%       estimation. Note that returning a 0 means the pose has not been
%       estimated.
%
% ## Options for Board
% * __objPoints__ array of object points of all the marker corners in the
%       board, i.e. their coordinates with respect to the board system. Each
%       marker include its 4 corners in CCW order
%       `{{[x1,y1],[x2,y2],[x3,y3],[x4,y4]}, ..}`.
% * __dictionary__ the dictionary of markers employed for this board. This is
%       specified in the same format described in cv.detectMarkers.
% * __ids__ vector of the identifiers of the markers in the board (same size
%       as `objPoints`). The identifiers refers to the board dictionary
%       (0-based).
%
% ## Options for GridBoard
% * __markersX__ number of markers in X direction.
% * __markersY__ number of markers in Y direction.
% * __markerLength__ marker side length (normally in meters).
% * __markerSeparation__ separation between two markers in the grid (same unit
%       as `markerLenght`).
% * __dictionary__ dictionary of markers indicating the type of markers. The
%       first `markersX*markersY` markers in the dictionary are used. This is
%       specified in the same format described in cv.detectMarkers.
%
% ## Options for CharucoBoard
% * __squaresX__ number of chessboard squares in X direction.
% * __squaresY__ number of chessboard squares in Y direction.
% * __squareLength__ chessboard square side length (normally in meters).
% * __markerLength__ marker side length (same unit as `squareLength`)
% * __dictionary__ dictionary of markers indicating the type of markers.
%       The first markers in the dictionary are used to fill the white
%       chessboard squares. This is specified in the same format described in
%       cv.detectMarkers.
%
% The cv.estimatePoseBoard function receives the detected markers and returns
% the pose of a marker board composed by those markers. A noard of marker has
% a single world coordinate system which is defined by the board layout. The
% returned transformation is the one that transforms points from the board
% coordinate system to the camera coordinate system. Input markers that are
% not included in the board layout are ignored.
%
% # Board of markers
%
% A board is a set of markers in the 3D space with a common cordinate system.
% The common form of a board of marker is a planar (2D) board, however any 3D
% layout can be used.
%
% # Grid Board
%
% A GridBoard is a special case of planar boards with grid arrangement of
% markers. It is the most common type of board. All markers are placed in the
% same plane in a grid arrangment.
%
% # ChArUco board
%
% Specific class for ChArUco boards. A ChArUco board is a planar board where
% the markers are placed inside the white squares of a chessboard. The
% benefits of ChArUco boards is that they provide both, ArUco markers
% versatility and chessboard corner precision, which is important for
% calibration and pose estimation.
%
% See also: cv.detectMarkers, cv.estimatePoseSingleMarkers, cv.Rodrigues,
%  cv.solvePnP
%
