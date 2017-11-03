%% Camera Calibration using ChArUco Boards Demo
% Calibration using a ChArUco board.
%
% To capture a frame for calibration, press 'c',
% If input comes from video, press any key for next frame
% To finish capturing, press 'ESC' key and calibration starts.
%
% Sources:
%
% * <https://docs.opencv.org/3.1.0/da/d13/tutorial_aruco_calibration.html>
% * <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/aruco/samples/calibrate_camera_charuco.cpp>
%

%% Parameters

% options
vidFile = '';                   % Use video file instead of camera as input
squaresX = 5;                   % Number of squares in X direction
squaresY = 7;                   % Number of squares in Y direction
squareLength = 60;              % Square side length (in pixels)
markerLength = 30;              % Marker side length (in pixels)
dictionaryId = '6x6_250';       % Dictionary id
refindStrategy = false;         % Apply refined strategy
showChessboardCorners = false;  % Show detected chessboard corners after calibration
calibrationFlags = {
    'UseIntrinsicGuess',false, ...
    'FixAspectRatio',false, ...     % Fix aspect ratio (fx/fy)
    'ZeroTangentDist',false, ...    % Assume zero tangential distortion
    'FixPrincipalPoint',false       % Fix the principal point at the center
};
aspectRatio = 1;                    % Fix aspect ratio (fx/fy) to this value

% FixAspectRatio in camera parameters
if calibrationFlags{4}
    camMatrix = eye(3);
    camMatrix(1,1) = aspectRatio;
    calibrationFlags = [calibrationFlags, 'CameraMatrix',camMatrix];
end

% marker detector parameters
detectorParams = struct();
if false
    %detectorParams.nMarkers = 1024;
    detectorParams.adaptiveThreshWinSizeMin = 3;
    detectorParams.adaptiveThreshWinSizeMax = 23;
    detectorParams.adaptiveThreshWinSizeStep = 10;
    detectorParams.adaptiveThreshConstant = 7;
    detectorParams.minMarkerPerimeterRate = 0.03;
    detectorParams.maxMarkerPerimeterRate = 4.0;
    detectorParams.polygonalApproxAccuracyRate = 0.05;
    detectorParams.minCornerDistanceRate = 0.05;
    detectorParams.minDistanceToBorder = 3;
    detectorParams.minMarkerDistanceRate = 0.05;
    detectorParams.cornerRefinementMethod = 'None';
    detectorParams.cornerRefinementWinSize = 5;
    detectorParams.cornerRefinementMaxIterations = 30;
    detectorParams.cornerRefinementMinAccuracy = 0.1;
    detectorParams.markerBorderBits = 1;
    detectorParams.perspectiveRemovePixelPerCell = 8;
    detectorParams.perspectiveRemoveIgnoredMarginPerCell = 0.13;
    detectorParams.maxErroneousBitsInBorderRate = 0.04;
    detectorParams.minOtsuStdDev = 5.0;
    detectorParams.errorCorrectionRate = 0.6;
end

% create charuco board
dictionary = {'Predefined', dictionaryId};
board = {squaresX, squaresY, squareLength, markerLength, dictionary};

%% Input source
if ~isempty(vidFile) && exist(vidFile, 'file') == 2
    vid = cv.VideoCapture(vidFile);
    waitTime = 1;     % 1 sec
else
    vid = cv.VideoCapture(0);
    waitTime = 0.01;  % 10 msec
end
if ~vid.isOpened(), error('failed to initialize VideoCapture'); end

%% Collect

% collect data from each frame
allCorners = {};
allIds = {};
allImgs = {};
imgSize = [];
hImg = []; hFig = [];
while true
    % grab frame
    img = vid.read();
    if isempty(img), break; end

    % detect markers
    [corners, ids, rejected] = cv.detectMarkers(img, dictionary, ...
        'DetectorParameters',detectorParams);

    % refined strategy to detect more markers
    if refindStrategy
        [corners, ids, rejected] = cv.refineDetectedMarkers(img, ...
            ['CharucoBoard',board], corners, ids, rejected);
    end

    % interpolate charuco corners
    if ~isempty(ids)
        [charucoCorners, charucoIds] = cv.interpolateCornersCharuco(...
            corners, ids, img, board);
    end

    % draw results
    out = img;
    if ~isempty(ids)
        out = cv.drawDetectedMarkers(out, corners);  % 'IDs',ids
        if ~isempty(charucoCorners)
            out = cv.drawDetectedCornersCharuco(out, charucoCorners, ...
                'IDs',charucoIds);
        end
    end
    out = cv.putText(out, ['Press "c" to add current frame. ', ...
        '"ESC" to finish and calibrate'], [10 20], ...
        'FontScale',0.5, 'Color',[255 0 0], 'Thickness',2);

    if isempty(hImg)
        hImg = imshow(out);
        hFig = ancestor(hImg, 'figure');
        set(hFig, 'KeyPressFcn',@(o,e) setappdata(o, 'key',e.Key));
        setappdata(hFig, 'key','');
    elseif ishghandle(hImg)
        set(hImg, 'CData',out);
    else
        break;
    end
    drawnow; pause(waitTime);

    % collect frame
    switch getappdata(hFig, 'key')
        case {'space', 'return', 'c'}
            if ~isempty(ids)
                fprintf('Frame captured at %s\n', datestr(now()));
                allCorners{end+1} = corners;
                allIds{end+1} = ids;
                allImgs{end+1} = img;
                imgSize = size(img);
            else
                disp('frame skipped, no corners detected!');
            end
        case {'escape', 'q'}
            disp('Finished collecting frames.');
            break;
        case 'p'
            pause(5);
    end
    setappdata(hFig, 'key','');
end
vid.release();

%% Calibration
disp('Calibrating...')

% calibrate camera using aruco markers
if isempty([allIds{:}]), error('Not enough captures for calibration'); end
[camMatrix, distCoeffs, arucoRepErr] = ...
    cv.calibrateCameraAruco([allCorners{:}], [allIds{:}], ...
        cellfun(@numel, allCorners), ['CharucoBoard',board], ...
        imgSize([2 1]), calibrationFlags{:});

% prepare data for charuco calibration
allCharucoCorners = cell(size(allCorners));
allCharucoIds = cell(size(allCorners));
for i=1:numel(allCorners)
    % interpolate using camera parameters
    [allCharucoCorners{i}, allCharucoIds{i}] = cv.interpolateCornersCharuco(...
        allCorners{i}, allIds{i}, allImgs{i}, board, ...
        'CameraMatrix',camMatrix, 'DistCoeffs',distCoeffs);
    if isempty(allCharucoIds{i})
        warning('interpolateCornersCharuco found no corners');
    end
end

% drop images where it failed to interpolate charuco corners
idx = cellfun(@isempty, allCharucoIds);
allCharucoIds(idx) = [];
allCharucoCorners(idx) = [];
allImgs(idx) = [];

% calibrate camera using charuco
if numel(allCharucoCorners) < 4, error('Not enough corners for calibration'); end
[camMatrix, distCoeffs, repError, rvecs, tvecs] = ...
    cv.calibrateCameraCharuco(allCharucoCorners, allCharucoIds, board, ...
        imgSize([2 1]), calibrationFlags{:});

% calibration results
fprintf('Calibration Time: %s\n', datestr(now()));
fprintf('Image Width: %d, Image Height: %d\n', imgSize(2), imgSize(1));
disp('Flags:'); cellfun(@disp,calibrationFlags);
if calibrationFlags{4}, fprintf('Aspect Ratio: %f\n', aspectRatio); end
disp('Camera Matrix:'); disp(camMatrix)
disp('Distortion Coefficients:'); disp(distCoeffs)
fprintf('Reprojection Error: Charuco = %f, Aruco = %f\n', repError, arucoRepErr);
save camera_parameters.mat -mat camMatrix distCoeffs

% show interpolated charuco corners for debugging
if showChessboardCorners
    axisLength = 0.5 * min(squaresX, squaresY) * squareLength;
    outImgs = {};
    for i=1:numel(allImgs)
        if ~isempty(allIds{i}) && ~isempty(allCharucoCorners)
            img = cv.drawDetectedCornersCharuco(...
                allImgs{i}, allCharucoCorners{i}, 'IDs',allCharucoIds{i});
            img = cv.drawAxis(img, camMatrix, distCoeffs, ...
                rvecs{i}, tvecs{i}, axisLength);
            outImgs{end+1} = img;
        end
    end
    if ~mexopencv.isOctave() && mexopencv.require('images')
        %HACK: IMPLAY not implemented in Octave
        implay(cat(4, outImgs{:}), 1);
    end
end
