classdef TestStereoRectify
    %TestStereoRectify
    properties (Constant)
        fields = {'R1', 'R2', 'P1', 'P2', 'Q', 'roi1', 'roi2'};
    end

    methods (Static)
        function test_1
            [opts, ipts1, ipts2, imgSize] = getPointsPair();
            SS = cv.stereoCalibrate(opts, ipts1, ipts2, imgSize);
            S = cv.stereoRectify(SS.cameraMatrix1, SS.distCoeffs1, ...
                SS.cameraMatrix2, SS.distCoeffs2, imgSize, SS.R, SS.T);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestStereoRectify.fields, fieldnames(S))));
            validateattributes(S.R1, {'numeric'}, {'size',[3 3]});
            validateattributes(S.R2, {'numeric'}, {'size',[3 3]});
            validateattributes(S.P1, {'numeric'}, {'size',[3 4]});
            validateattributes(S.P2, {'numeric'}, {'size',[3 4]});
            validateattributes(S.Q, {'numeric'}, {'size',[4 4]});
            validateattributes(S.roi1, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
            validateattributes(S.roi2, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
        end

        function test_2
            imageSize = [640 480];
            cam1 = eye(3);
            cam2 = eye(3);
            distort1 = zeros(1,5);
            distort2 = zeros(1,5);
            R = [cv.getRotationMatrix2D(imageSize./2, 0, 1); 0 0 1];
            T = [1; 0; 0];
            S = cv.stereoRectify(cam1, distort1, cam2, distort2, imageSize, ...
                R, T, 'ZeroDisparity',false, 'Alpha',-1, ...
                'NewImageSize',imageSize./2);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestStereoRectify.fields, fieldnames(S))));
            validateattributes(S.R1, {'numeric'}, {'size',[3 3]});
            validateattributes(S.R2, {'numeric'}, {'size',[3 3]});
            validateattributes(S.P1, {'numeric'}, {'size',[3 4]});
            validateattributes(S.P2, {'numeric'}, {'size',[3 4]});
            validateattributes(S.Q, {'numeric'}, {'size',[4 4]});
            validateattributes(S.roi1, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
            validateattributes(S.roi2, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
        end

        function test_error_1
            try
                cv.stereoRectify();
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
