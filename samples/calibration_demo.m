function calibration_demo
%CALIBRATION_DEMO demonstration of stereo calibration

% Prepare calibration patterns
files_l = dir(fullfile(mexopencv.root(),'test','left*.jpg'));
files_r = dir(fullfile(mexopencv.root(),'test','right*.jpg'));
assert(numel(files_l) == numel(files_r));
mesh_size = [9,6];
[mesh_x,mesh_y] = ndgrid(1:mesh_size(1),1:mesh_size(2));
mesh_coord = num2cell([mesh_x(:),mesh_y(:),zeros(numel(mesh_x),1)],2)';

% Find coordinates
pts_o = cell(1,numel(files_l));
pts_l = cell(1,numel(files_l));
pts_r = cell(1,numel(files_r));
for i = 1:numel(files_l)
    im_l = imread(fullfile(mexopencv.root(),'test',files_l(i).name));
    im_r = imread(fullfile(mexopencv.root(),'test',files_r(i).name));
    pts_l_ = cv.findChessboardCorners(im_l, mesh_size);
    pts_l{i} = cv.cornerSubPix(im_l,pts_l_);
    pts_r_ = cv.findChessboardCorners(im_r, mesh_size);
    pts_r{i} = cv.cornerSubPix(im_r,pts_r_);
    pts_o{i} = mesh_coord;
end

% Calibrate
siz = [size(im_l,2),size(im_l,1)];
S = cv.stereoCalibrate(pts_o, pts_l, pts_r, siz,...
    'FixAspectRatio',  true,...
    'ZeroTangentDist', true,...
    'SameFocalLength', true,...
    'RationalModel',   true,...
    'FixK3',           true,...
    'FixK4',           true,...
    'FixK5',           true);
fprintf('RMS error: %f\n',S.d);

% Rectification
RCT = cv.stereoRectify(S.cameraMatrix1, S.distCoeffs1,...
    S.cameraMatrix2, S.distCoeffs2, siz, S.R, S.T,...
    'ZeroDisparity', true);

% Prepare maps for drawing
RM = struct('map1',cell(1,2),'map2',cell(1,2));
[RM(1).map1, RM(1).map2] = cv.initUndistortRectifyMap(...
    S.cameraMatrix1, S.distCoeffs1, RCT.P1, siz,...
    'R', RCT.R1, 'M1Type', 'int16');
[RM(2).map1, RM(2).map2] = cv.initUndistortRectifyMap(...
    S.cameraMatrix2, S.distCoeffs2, RCT.P2, siz,...
    'R', RCT.R2, 'M1Type', 'int16');

% Draw
fprintf('Press any key to continue:\n');
sf = (600/max(siz));
[w,h] = deal(siz(1)*sf,siz(2)*sf);
for i = 1:numel(files_l)
    fprintf(' % 3d / % 3d\n', i, numel(files_l));
    im_l = imread(fullfile(mexopencv.root(),'test',files_l(i).name));
    im_r = imread(fullfile(mexopencv.root(),'test',files_r(i).name));
    rim_l = cv.remap(im_l, RM(1).map1, RM(1).map2);
    rim_r = cv.remap(im_r, RM(2).map1, RM(2).map2);
    cim_l = cv.cvtColor(rim_l, 'GRAY2RGB');
    cim_r = cv.cvtColor(rim_r, 'GRAY2RGB');
    canvas = zeros(h,2*w,3,'uint8');
    canvas(1:end,1:w,:) = cv.resize(cim_l,[w,h]);
    canvas(1:end,w+1:end,:) = cv.resize(cim_r,[w,h]);
    imshow(canvas);
    % draw horizontal lines
    Y = repmat(1:16:size(canvas,1),2,1);
    X = repmat([1;size(canvas,2)],1,size(Y,2));
    line(X,Y,'Color','g');
    % draw valid roi
    roi1 = round([RCT.roi1(1:2)+1,RCT.roi1(3:4)]*sf);
    rectangle('Position',roi1,'EdgeColor','b');
    roi2 = round([RCT.roi2(1)+w+1,RCT.roi2(2)+1,RCT.roi1(3:4)]*sf);
    rectangle('Position',roi2,'EdgeColor','b');
    pause(1);
end
fprintf('Done\n');
close all;

end

