%% Stereo Calibration demo
% Demonstration of stereo calibration
%
% You will learn how to use the following OpenCV functions and classes:
%
% * cv.findChessboardCorners
% * cv.cornerSubPix
% * cv.drawChessboardCorners
% * cv.initCameraMatrix2D
% * cv.stereoCalibrate
% * cv.stereoRectify
% * cv.initUndistortRectifyMap
% * cv.remap
% * cv.StereoBM, cv.StereoSGBM
% * cv.filterSpeckles
% * cv.reprojectImageTo3D
%
% <https://github.com/Itseez/opencv/blob/3.0.0/samples/cpp/stereo_calib.cpp>
%
% See also: StereoCalibrationAndSceneReconstructionExample
%

%% Stereo Images
files_l = dir(fullfile(mexopencv.root(),'test','left*.jpg'));
files_r = dir(fullfile(mexopencv.root(),'test','right*.jpg'));
files_l = strcat(fullfile(mexopencv.root(),'test'), filesep, {files_l.name});
files_r = strcat(fullfile(mexopencv.root(),'test'), filesep, {files_r.name});
assert(numel(files_l) == numel(files_r));
N = numel(files_l);
patternSize = [9,6];

%{
if ~license('test', 'video_and_image_blockset')
    error('CVST not found');
end
%fpath = fullfile(matlabroot,'toolbox','vision','visiondata','calibration','stereoWebcams');
fpath = fullfile(matlabroot,'toolbox','vision','visiondata','calibration','stereo');
files_l = dir(fullfile(fpath, 'left', 'left*.png'));
files_r = dir(fullfile(fpath, 'right', 'right*.png'));
files_l = strcat(fullfile(fpath, 'left'), filesep, {files_l.name});
files_r = strcat(fullfile(fpath, 'right'), filesep, {files_r.name});
assert(numel(files_l) == numel(files_r));
N = numel(files_l);
patternSize = [7,6];
%}

info = imfinfo(files_l{1});
imgSiz = [info.Width, info.Height];
fprintf('%d stereo image pairs\n', N);
fprintf('Image size = %dx%d\n', imgSiz);
fprintf('Pattern size = %dx%d\n', patternSize);
disp(files_l(:)); disp(files_r(:))

%% Object Points
% Prepare calibration patterns
%TODO: square size in actual units of measurements
[X,Y] = ndgrid(1:patternSize(1), 1:patternSize(2));
pts_o = num2cell([X(:) Y(:) zeros(prod(patternSize),1)], 2)';  % Z=0
pts_o = repmat({pts_o}, 1, N);  % same calibration coords used in all views

%% Image Points
% Find coordinates of chessboard corners in left/right images
pts_l = cell(1,N);
pts_r = cell(1,N);
options = {'WinSize',[11 11], 'Criteria',...
    struct('type','Count+EPS', 'maxCount',30, 'epsilon',0.01)};
for i=1:N
    im_l = cv.imread(files_l{i}, 'Grayscale',true);
    im_r = cv.imread(files_r{i}, 'Grayscale',true);
    tic
    pts_l{i} = cv.findChessboardCorners(im_l, patternSize);
    pts_r{i} = cv.findChessboardCorners(im_r, patternSize);
    pts_l{i} = cv.cornerSubPix(im_l, pts_l{i}, options{:});
    pts_r{i} = cv.cornerSubPix(im_r, pts_r{i}, options{:});
    toc
end

%%
% Show detected checkerboards in first pair of images
i = min(1, N);
im_l = cv.imread(files_l{i}, 'Color',true);
im_r = cv.imread(files_r{i}, 'Color',true);
im_l = cv.drawChessboardCorners(im_l, patternSize, pts_l{i});
im_r = cv.drawChessboardCorners(im_r, patternSize, pts_r{i});
imshow(cat(2, im_l, im_r))

%% Calibration
% calibrate the stereo camera, specifying the distortion model in the options
tic
%M_l = cv.initCameraMatrix2D(pts_o, pts_l, imgSiz);
%M_r = cv.initCameraMatrix2D(pts_o, pts_r, imgSiz);
S = cv.stereoCalibrate(pts_o, pts_l, pts_r, imgSiz, ...
    ... 'CameraMatrix1',M_l, 'CameraMatrix2',M_r, 'UseIntrinsicGuess',true, ...
    'SameFocalLength',true, ...
    'FixAspectRatio', true, ...
    'ZeroTangentDist',true, ...
    'RationalModel',  true, ...
    'FixK3',          true, ...
    'FixK4',          true, ...
    'FixK5',          true, ...
    'FixIntrinsic',   false, ...
    'Criteria',struct('type','Count+EPS', 'maxCount',100, 'epsilon',1e-5));
toc

% calibration accuracy
assert(all(isfinite([S.cameraMatrix1(:); S.cameraMatrix2(:)])));
assert(all(isfinite([S.distCoeffs1(:); S.distCoeffs2(:)])));
fprintf('Total RMS reprojection error: %f\n', S.reprojErr);
display(S)

%% Rectification
% compute rectification transforms for the two camera heads
tic
RCT = cv.stereoRectify(S.cameraMatrix1, S.distCoeffs1,...
    S.cameraMatrix2, S.distCoeffs2, imgSiz, S.R, S.T, ...
    'ZeroDisparity',true, 'Alpha',-1);
toc

display(RCT)

%%
% combined transformations to rectify images and remove distortions
tic
RM = struct('map1',cell(1,2), 'map2',cell(1,2));
[RM(1).map1, RM(1).map2] = cv.initUndistortRectifyMap(...
    S.cameraMatrix1, S.distCoeffs1, RCT.P1, imgSiz, ...
    'R',RCT.R1, 'M1Type','int16');
[RM(2).map1, RM(2).map2] = cv.initUndistortRectifyMap(...
    S.cameraMatrix2, S.distCoeffs2, RCT.P2, imgSiz, ...
    'R',RCT.R2, 'M1Type','int16');
toc

whos RM
display(RM(1))

%% Draw
% show rectified images

% prepare image montage
sf = min(1, 600/max(imgSiz));  % avoid having images too big for display
[w,h] = deal(round(imgSiz(1)*sf), round(imgSiz(2)*sf));
hImg = imshow(zeros([h,w*2,3], 'uint8'));

% prepare for drawing 30 horizontal lines
k = 30;
X = repmat([1;w*2], [1 k]);
Y = repmat(linspace(1,h,k), [2 1]);
XY = num2cell(reshape(num2cell(round([X(:) Y(:)]-1), 2), 2, []), 1);

% prepare for drawing valid ROI
roi_l = round(RCT.roi1*sf);
roi_r = round(RCT.roi2*sf + [w 0 0 0]);  % shifted to right

% loop over pairs of images
for i=1:N
    % undistort+rectify left/right images
    im_l = cv.imread(files_l{i}, 'Color',true);
    im_r = cv.imread(files_r{i}, 'Color',true);
    %im_l = cv.drawChessboardCorners(im_l, patternSize, pts_l{i});
    %im_r = cv.drawChessboardCorners(im_r, patternSize, pts_r{i});
    im_l = cv.remap(im_l, RM(1).map1, RM(1).map2, 'Interpolation','Linear');
    im_r = cv.remap(im_r, RM(2).map1, RM(2).map2, 'Interpolation','Linear');

    % combine images side-by-side
    im_l = cv.resize(im_l, [w,h], 'Interpolation','Area');
    im_r = cv.resize(im_r, [w,h], 'Interpolation','Area');
    canvas = cat(2, im_l, im_r);

    % draw horizontal lines and ROI rectangles
    canvas = cv.rectangle(canvas, roi_l, 'Color',[0 255 0], 'Thickness',3);
    canvas = cv.rectangle(canvas, roi_r, 'Color',[0 255 0], 'Thickness',3);
    canvas = cv.polylines(canvas, XY,    'Color',[255 0 0], 'Thickness',1);

    % show final image
    set(hImg, 'CData',canvas);
    title(sprintf('Rectified: %02d / %02d', i, N));
    pause(1);
end

%% Disparity Map

% pick a pair of rectified images
i = min(6, N);
im_l = cv.imread(files_l{i}, 'Color',true);
im_r = cv.imread(files_r{i}, 'Color',true);
im_l = cv.remap(im_l, RM(1).map1, RM(1).map2);
im_r = cv.remap(im_r, RM(2).map1, RM(2).map2);

% compute disparity
bm = cv.StereoSGBM();
bm.NumDisparities = 128;
bm.BlockSize = 25;
bm.SpeckleRange = 4;
bm.SpeckleWindowSize = 200;
tic
D = bm.compute(rgb2gray(im_l), rgb2gray(im_r));
toc

%D = cv.filterSpeckles(D, 0, 200, 4); % remove small blobs
D = min(D, 2000);                     % truncate values
imshow(D,[]), title('Disparity Map')
colormap gray; colorbar;

%% 3D Reconstruction
tic
im3d = cv.reprojectImageTo3D(D, RCT.Q);
toc
%X = im3d(:,:,1);  % TODO
%Y = im3d(:,:,2);
%Z = im3d(:,:,3);

% visualize point cloud
[X,Y] = ndgrid(1:size(D,1), 1:size(D,2));
Z = D(:);                            % XYZ-coords of point cloud
C = reshape(im2double(im_l), [], 3); % corresponding color
scatter3(X(:), Y(:), Z(:), 6, C, '.')
axis tight; daspect([1 1 3]);
title('Point Cloud'); xlabel X; ylabel Y; zlabel Z;
% set camera for a better scene look
%cameratoolbar
campos([-15 -15 70]*100)
camtarget([2 5 10]*100)
camup([-1 1 -5])
camva(15)
