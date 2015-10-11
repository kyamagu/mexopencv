classdef TestReprojectImageTo3D
    %TestReprojectImageTo3D

    methods (Static)
        function test_1
            D = randi([-20 1000], [200 300], 'int16');
            Q = [1 0 0 -rand()*100; 0 1 0 -rand()*100; 0 0 0 rand()*500; 0 0 rand() 0];
            im3d = cv.reprojectImageTo3D(D, Q, ...
                'HandleMissingValues',false, 'Depth','single');
            validateattributes(im3d, {'single'}, {'size',[size(D) 3]});
        end

        function test_2
            % calibrate
            N = 6;
            opts = cell(1,N);
            ipts2 = cell(1,N);
            ipts1 = cell(1,N);
            for i=1:N
                [opts{i}, ipts1{i}, ipts2{i}, imgSize, img1, img2] = getPointsPair(i);
            end
            S = cv.stereoCalibrate(opts, ipts1, ipts2, imgSize, ...
                'FixIntrinsic',false);

            % rectify
            RCT = cv.stereoRectify(S.cameraMatrix1, S.distCoeffs1, ...
                S.cameraMatrix2, S.distCoeffs2, imgSize, S.R, S.T);
            [map11, map12] = cv.initUndistortRectifyMap(S.cameraMatrix1, ...
                S.distCoeffs1, RCT.P1, imgSize, 'R',RCT.R1);
            [map21, map22] = cv.initUndistortRectifyMap(S.cameraMatrix2, ...
                S.distCoeffs2, RCT.P2, imgSize, 'R',RCT.R2);
            img1 = cv.remap(img1, map11, map12);
            img2 = cv.remap(img2, map21, map22);

            % compute disparity
            bm = cv.StereoSGBM();
            bm.NumDisparities = 128;
            bm.BlockSize = 13;
            D = bm.compute(img1, img2);

            % reproject
            im3d = cv.reprojectImageTo3D(D, RCT.Q);
            validateattributes(im3d, {'single'}, {'size',[size(D) 3]});
        end

        function test_error_1
            try
                cv.reprojectImageTo3D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [opts, ipts1, ipts2, imgSize, img1, img2] = getPointsPair(N)
    % consider only the first nine images
    if nargin < 1, N = 1; end
    assert(N <= 9);

    % object points
    patternsize = [9 6];
    [X,Y] = ndgrid(1:patternsize(1), 1:patternsize(2));
    opts = [X(:) Y(:) zeros(prod(patternsize),1)];  % Z=0

    % image points 1
    img1 = imread(fullfile(mexopencv.root(),'test',sprintf('left0%d.jpg',N)));
    imgSize = [size(img1,2) size(img1,1)];
    ipts1 = cv.findChessboardCorners(img1, patternsize, 'FastCheck',true);
    ipts1 = cv.cornerSubPix(img1, ipts1);
    ipts1 = cat(1, ipts1{:});

    % image points 1
    img2 = imread(fullfile(mexopencv.root(),'test',sprintf('right0%d.jpg',N)));
    ipts2 = cv.findChessboardCorners(img2, patternsize, 'FastCheck',true);
    ipts2 = cv.cornerSubPix(img2, ipts2);
    ipts2 = cat(1, ipts2{:});
end
