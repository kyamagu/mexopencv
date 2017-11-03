%% Detection of ArUco Markers Demo
% Basic marker detection and pose estimation from single ArUco markers.
%
% Sources:
%
% * <https://docs.opencv.org/3.1.0/d5/dae/tutorial_aruco_detection.html>
% * <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/aruco/samples/detect_markers.cpp>
%

%% Parameters

% options
vidFile = '';              % Use video file instead of camera as input
markerLength = 0.1;        % Marker side length (in meters). Needed for correct scale in camera pose
dictionaryId = '6x6_250';  % Dictionary id
showRejected = false;      % Show rejected candidates too
estimatePose = false;      % Wheather to estimate pose or not
if estimatePose
    % Camera intrinsic parameters. Needed for camera pose
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
detectorParams.cornerRefinementMethod = 'Subpix';  % do corner refinement in markers

% dictionary
dictionary = {'Predefined', dictionaryId};

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

    % detect markers and estimate pose
    [corners, ids, rejected] = cv.detectMarkers(img, dictionary, ...
        'DetectorParameters',detectorParams);

    if estimatePose && ~isempty(ids)
        [rvecs, tvecs] = cv.estimatePoseSingleMarkers(corners, ...
            markerLength, camMatrix, distCoeffs);
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

        if estimatePose
            for i=1:numel(ids)
                img = cv.drawAxis(img, camMatrix, distCoeffs, ...
                    rvecs{i}, tvecs{i}, markerLength * 0.5);
            end
        end
    end

    if showRejected && ~isempty(rejected)
        img = cv.drawDetectedMarkers(img, rejected, 'BorderColor',[255 0 100]);
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
