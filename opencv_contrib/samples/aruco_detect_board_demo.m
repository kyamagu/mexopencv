%% Detection of ArUco Boards Demo
% Detection and pose estimation using a Board of markers
% (an ArUco Planar Grid board).
%
% <http://docs.opencv.org/3.1.0/db/da9/tutorial_aruco_board_detection.html>
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/aruco/samples/detect_board.cpp>
%

%% Parameters

% options
vidFile = '';              % Use video file instead of camera as input
markersX = 5;              % Number of markers in X direction
markersY = 7;              % Number of markers in Y direction
markerLength = 60;         % Marker side length (in pixels)
markerSeparation = 10;     % Separation between two consecutive markers in the grid (in pixels)
dictionaryId = '6x6_250';  % Dictionary id
showRejected = false;      % Show rejected candidates too
refindStrategy = true;     % Apply refined strategy
estimatePose = false;      % Wheather to estimate pose or not
if estimatePose
    % calibrated camera parameters
    load camera_parameters.mat camMatrix distCoeffs
    %camMatrix = eye(3);
    %distCoeffs = zeros(1,5);
else
    camMatrix = [];
    distCoeffs = [];
end

% marker detector parameters
detectorParams = struct();
if false
    detectorParams.nMarkers = 1024;
    detectorParams.adaptiveThreshWinSizeMax = 21;
    detectorParams.adaptiveThreshConstant = 7;
    detectorParams.minMarkerPerimeterRate = 0.03;
    detectorParams.maxMarkerPerimeterRate = 4.0;
    detectorParams.polygonalApproxAccuracyRate = 0.05;
    detectorParams.minCornerDistanceRate = 10.0;
    detectorParams.minDistanceToBorder = 3;
    detectorParams.minMarkerDistanceRate = 10.0;
    detectorParams.cornerRefinementWinSize = 5;
    detectorParams.cornerRefinementMaxIterations = 30;
    detectorParams.cornerRefinementMinAccuracy = 0.1;
    detectorParams.markerBorderBits = 1;
    detectorParams.perspectiveRemovePixelPerCell = 8;
    detectorParams.perspectiveRemoveIgnoredMarginPerCell = 0.13;
    detectorParams.maxErroneousBitsInBorderRate = 0.04;
end
detectorParams.doCornerRefinement = true;  % do corner refinement in markers

% create board
dictionary = {'Predefined', dictionaryId};
board = {'GridBoard', ...
    markersX, markersY, markerLength, markerSeparation, dictionary};

axisLength = 0.5 * (min(markersX, markersY) * ...
    (markerLength + markerSeparation) + markerSeparation);

%% Input source
if ~isempty(vidFile) && exist(vidFile, 'file')
    vid = cv.VideoCapture(vidFile);
    waitTime = 1;     % 1 sec
else
    vid = cv.VideoCapture(0);
    waitTime = 0.01;  % 10 msec
end
if ~vid.isOpened(), error('failed to initialize VideoCapture'); end

%% Main loop
totalTime = 0;
totalIterations = 0;
hImg = gobjects(0);
while true
    % grab frame
    img = vid.read();
    if isempty(img), break; end

    tId = tic();

    % detect markers
    [corners, ids, rejected] = cv.detectMarkers(img, dictionary, ...
        'DetectorParameters',detectorParams);

    % refined strategy to detect more markers
    if refindStrategy
        [corners, ids, rejected] = cv.refineDetectedMarkers(img, board, ...
            corners, ids, rejected, ...
            'CameraMatrix',camMatrix, 'DistCoeffs',distCoeffs);
    end

    % estimate board pose
    markersOfBoardDetected = 0;
    if estimatePose && ~isempty(ids)
        [rvec, tvec, markersOfBoardDetected] = ...
            cv.estimatePoseBoard(corners, ids, board, camMatrix, distCoeffs);
    end

    % tic/toc
    currentTime = toc(tId);
    totalTime = totalTime + currentTime;
    totalIterations = totalIterations + 1;
    if mod(totalIterations, 30) == 0
        fprintf('Detection time = %f ms (Mean = %f ms)\n', ...
            1000*currentTime, 1000*totalTime/totalIterations);
    end

    % draw results
    if ~isempty(ids)
        img = cv.drawDetectedMarkers(img, corners, 'IDs',ids);
    end

    if showRejected && ~isempty(rejected)
        img = cv.drawDetectedMarkers(img, rejected, 'BorderColor',[255 0 100]);
    end

    if estimatePose && markersOfBoardDetected > 0
        img = cv.drawAxis(img, camMatrix, distCoeffs, rvec, tvec, axisLength);
    end

    if isempty(hImg)
        hImg = imshow(img);
    elseif ishghandle(hImg)
        set(hImg, 'CData',img);
    else
        break;
    end
    drawnow; pause(waitTime);
end
vid.release();
