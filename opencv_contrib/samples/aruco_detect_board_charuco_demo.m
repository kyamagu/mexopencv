%% Detection of ChArUco Corners Demo
% The example shows how to do pose estimation using a ChArUco board.
%
% Sources:
%
% * <https://docs.opencv.org/3.1.0/df/d4a/tutorial_charuco_detection.html>
% * <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/aruco/samples/detect_board_charuco.cpp>
%

%% Parameters

% options
vidFile = '';              % Use video file instead of camera as input
squaresX = 5;              % Number of squares in X direction
squaresY = 7;              % Number of squares in Y direction
squareLength = 60;         % Square side length (in pixels)
markerLength = 30;         % Marker side length (in pixels)
dictionaryId = '6x6_250';  % Dictionary id
showRejected = false;      % Show rejected candidates too
refindStrategy = true;     % Apply refined strategy
estimatePose = false;      % Wheather to estimate pose or not
if estimatePose
    % calibrated camera parameters
    load camera_parameters.mat -mat camMatrix distCoeffs
    %camMatrix = eye(3);
    %distCoeffs = zeros(1,5);
else
    camMatrix = [];
    distCoeffs = [];
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

% create board
dictionary = {'Predefined', dictionaryId};
board = {squaresX, squaresY, squareLength, markerLength, dictionary};

axisLength = 0.5 * min(squaresX, squaresY) * squareLength;

%% Input source
if ~isempty(vidFile) && exist(vidFile, 'file') == 2
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
hImg = [];
while true
    % grab frame
    img = vid.read();
    if isempty(img), break; end

    tId = tic();

    % detect markers
    [markerCorners, markerIds, rejectedMarkers] = cv.detectMarkers(...
        img, dictionary, 'DetectorParameters',detectorParams);

    % refined strategy to detect more markers
    if refindStrategy
        [markerCorners, markerIds, rejectedMarkers] = ...
            cv.refineDetectedMarkers(img, ['CharucoBoard', board], ...
                markerCorners, markerIds, rejectedMarkers, ...
                'CameraMatrix',camMatrix, 'DistCoeffs',distCoeffs);
    end

    % interpolate charuco corners
    interpolatedCorners = 0;
    if ~isempty(markerIds)
        [charucoCorners, charucoIds, interpolatedCorners] = ...
            cv.interpolateCornersCharuco(markerCorners, markerIds, ...
                img, board, 'CameraMatrix',camMatrix, 'DistCoeffs',distCoeffs);
    end

    % estimate charuco board pose
    validPose = false;
    if estimatePose && ~isempty(charucoIds)
        [rvec, tvec, validPose] = cv.estimatePoseCharucoBoard(...
            charucoCorners, charucoIds, board, camMatrix, distCoeffs);
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
    if ~isempty(markerIds)
        img = cv.drawDetectedMarkers(img, markerCorners);  % 'IDs',markerIds
    end

    if showRejected && ~isempty(rejectedMarkers)
        img = cv.drawDetectedMarkers(img, rejectedMarkers, ...
            'BorderColor',[255 0 100]);
    end

    if interpolatedCorners > 0
        img = cv.drawDetectedCornersCharuco(img, charucoCorners, ...
            'IDs',charucoIds, 'CornerColor',[255 0 0]);
    end

    if estimatePose && validPose
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
