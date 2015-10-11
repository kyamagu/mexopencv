classdef TestStereoCalibrate
    %TestStereoCalibrate
    properties (Constant)
        fields = {'cameraMatrix1', 'distCoeffs1', ...
            'cameraMatrix2', 'distCoeffs2', 'R', 'T', 'E', 'F', 'reprojErr'};
    end

    methods (Static)
        function test_one_view
            [opts, ipts1, ipts2, imgSize] = getPointsPair();
            S = cv.stereoCalibrate(opts, ipts1, ipts2, imgSize);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestStereoCalibrate.fields, fieldnames(S))));
            validateattributes(S.cameraMatrix1, {'numeric'}, {'size',[3 3]});
            validateattributes(S.cameraMatrix2, {'numeric'}, {'size',[3 3]});
            validateattributes(S.distCoeffs1, {'numeric'}, {'vector', 'numel',5});
            validateattributes(S.distCoeffs2, {'numeric'}, {'vector', 'numel',5});
            validateattributes(S.R, {'numeric'}, {'size',[3 3]});
            validateattributes(S.T, {'numeric'}, {'vector', 'numel',3});
            validateattributes(S.E, {'numeric'}, {'size',[3 3]});
            validateattributes(S.F, {'numeric'}, {'size',[3 3]});
            validateattributes(S.reprojErr, {'numeric'}, {'scalar'});
        end

        function test_multiple_views
            N = 9;
            opts = cell(1,N);
            ipts1 = cell(1,N);
            ipts2 = cell(1,N);
            for i=1:N
                [opts{i}, ipts1{i}, ipts2{i}, imgSize] = getPointsPair(i);
            end
            S = cv.stereoCalibrate(opts, ipts1, ipts2, imgSize);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestStereoCalibrate.fields, fieldnames(S))));
            validateattributes(S.cameraMatrix1, {'numeric'}, {'size',[3 3]});
            validateattributes(S.cameraMatrix2, {'numeric'}, {'size',[3 3]});
            validateattributes(S.distCoeffs1, {'numeric'}, {'vector', 'numel',5});
            validateattributes(S.distCoeffs2, {'numeric'}, {'vector', 'numel',5});
            validateattributes(S.R, {'numeric'}, {'size',[3 3]});
            validateattributes(S.T, {'numeric'}, {'vector', 'numel',3});
            validateattributes(S.E, {'numeric'}, {'size',[3 3]});
            validateattributes(S.F, {'numeric'}, {'size',[3 3]});
            validateattributes(S.reprojErr, {'numeric'}, {'scalar'});
        end

        function test_options
            [opts, ipts1, ipts2, imgSize] = getPointsPair();
            camMtx1 = cv.initCameraMatrix2D(opts, ipts1, imgSize);
            camMtx2 = cv.initCameraMatrix2D(opts, ipts2, imgSize);
            S = cv.stereoCalibrate(opts, ipts1, ipts2, imgSize, ...
                'CameraMatrix1',camMtx1, 'CameraMatrix2',camMtx2, ...
                'ZeroTangentDist',true, 'RationalModel',true, ...
                'ThinPrismModel',true, 'FixAspectRatio',true, ...
                'FixPrincipalPoint',true, 'FixK3',true, ...
                'FixK4',true, 'FixK5',true, 'FixS1S2S3S4',true);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestStereoCalibrate.fields, fieldnames(S))));
            validateattributes(S.cameraMatrix1, {'numeric'}, {'size',[3 3]});
            validateattributes(S.cameraMatrix2, {'numeric'}, {'size',[3 3]});
            validateattributes(S.distCoeffs1, {'numeric'}, {'vector', 'numel',12});
            validateattributes(S.distCoeffs2, {'numeric'}, {'vector', 'numel',12});
            validateattributes(S.R, {'numeric'}, {'size',[3 3]});
            validateattributes(S.T, {'numeric'}, {'vector', 'numel',3});
            validateattributes(S.E, {'numeric'}, {'size',[3 3]});
            validateattributes(S.F, {'numeric'}, {'size',[3 3]});
            validateattributes(S.reprojErr, {'numeric'}, {'scalar'});
        end

        function test_error_1
            try
                cv.stereoCalibrate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [opts, ipts1, ipts2, imgSize] = getPointsPair(N)
    % consider only the first nine images
    if nargin < 1, N = 1; end
    assert(N <= 9);

    % object points
    patternsize = [9 6];
    [X,Y] = ndgrid(1:patternsize(1), 1:patternsize(2));
    opts = [X(:) Y(:) zeros(prod(patternsize),1)];  % Z=0

    % image points 1
    img = imread(fullfile(mexopencv.root(),'test',sprintf('left0%d.jpg',N)));
    imgSize = [size(img,2) size(img,1)];
    ipts1 = cv.findChessboardCorners(img, patternsize, 'FastCheck',true);
    ipts1 = cv.cornerSubPix(img, ipts1);
    ipts1 = cat(1, ipts1{:});

    % image points 1
    img = imread(fullfile(mexopencv.root(),'test',sprintf('right0%d.jpg',N)));
    ipts2 = cv.findChessboardCorners(img, patternsize, 'FastCheck',true);
    ipts2 = cv.cornerSubPix(img, ipts2);
    ipts2 = cat(1, ipts2{:});
end
