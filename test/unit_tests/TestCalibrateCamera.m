classdef TestCalibrateCamera
    %TestCalibrateCamera

    methods (Static)
        function test_one_view
            [opts, ipts, imgSize] = getPoints();
            [A, distCoeffs, err] = cv.calibrateCamera(opts, ipts, imgSize);
            [A, distCoeffs, err, rvecs, tvecs] = cv.calibrateCamera(opts, ipts, imgSize);
            validateattributes(A, {'numeric'}, {'size',[3 3]});
            validateattributes(distCoeffs, {'numeric'}, {'vector', 'numel',5});
            validateattributes(err, {'numeric'}, {'scalar'});
            validateattributes(rvecs, {'cell'}, {'vector', 'numel',1});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector', 'numel',1});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
        end

        function test_multiple_views
            N = 5;
            opts = cell(1,N);
            ipts = cell(1,N);
            for i=1:N
                [opts{i}, ipts{i}, imgSize] = getPoints(i);
            end
            [A, distCoeffs, err] = cv.calibrateCamera(opts, ipts, imgSize);
            [A, distCoeffs, err, rvecs, tvecs] = cv.calibrateCamera(opts, ipts, imgSize);
            [A, distCoeffs, err, rvecs, tvecs, stdDevsInt, stdDevsExt, errs] = ...
                cv.calibrateCamera(opts, ipts, imgSize);
            validateattributes(A, {'numeric'}, {'size',[3 3]});
            validateattributes(distCoeffs, {'numeric'}, {'vector', 'numel',5});
            validateattributes(err, {'numeric'}, {'scalar'});
            validateattributes(rvecs, {'cell'}, {'vector', 'numel',N});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector', 'numel',N});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
            validateattributes(stdDevsInt, {'numeric'}, {'vector', 'numel',18});
            validateattributes(stdDevsExt, {'numeric'}, {'vector', 'numel',N*6});
            validateattributes(errs, {'numeric'}, {'vector', 'numel',N});
        end

        function test_options
            [opts, ipts, imgSize] = getPoints();
            camMtx = cv.initCameraMatrix2D(opts, ipts, imgSize);
            [A, distCoeffs, err] = cv.calibrateCamera(opts, ipts, imgSize, ...
                'CameraMatrix',camMtx, 'UseIntrinsicGuess',true, ...
                'FixAspectRatio',true, 'FixPrincipalPoint',true, ...
                'ZeroTangentDist',true, 'FixK3',true, ...
                'RationalModel',true, 'FixK4',true, 'FixK5',true, ...
                'ThinPrismModel',true, 'FixS1S2S3S4',true, ...
                'TiltedModel',true, 'FixTauXTauY',true);
            validateattributes(A, {'numeric'}, {'size',[3 3]});
            validateattributes(distCoeffs, {'numeric'}, {'vector', 'numel',14});
            validateattributes(err, {'numeric'}, {'scalar'});
        end

        function test_error_argnum
            try
                cv.calibrateCamera();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [opts, ipts, imgSize] = getPoints(N)
    % consider only the first nine images
    if nargin < 1, N = 1; end
    assert(N <= 9);

    % object points
    patternsize = [9 6];
    [X,Y] = ndgrid(1:patternsize(1), 1:patternsize(2));
    opts = [X(:) Y(:) zeros(prod(patternsize),1)];  % Z=0

    % image points
    img = imread(fullfile(mexopencv.root(),'test',sprintf('left0%d.jpg',N)));
    imgSize = [size(img,2) size(img,1)];
    ipts = cv.findChessboardCorners(img, patternsize, 'FastCheck',true);
    ipts = cv.cornerSubPix(img, ipts);
    ipts = cat(1, ipts{:});
end

%{
function [opts, ipts, imgSize] = getPointsFake(~)
    % object points
    patternsize = [9 6];
    [X,Y] = ndgrid(1:patternsize(1), 1:patternsize(2));
    opts = [X(:) Y(:) zeros(prod(patternsize),1)];  % Z=0

    % image points
    imgSize = [600 400];
    ipts = bsxfun(@plus, bsxfun(@times, opts(:,1:2), [60 30]), [5 10]);
    ipts = ipts + randn(size(ipts));
    M = [cv.getRotationMatrix2D(imgSize./2, -10, 1.9); rand(1,2)*1e-3 1];
    ipts = cv.perspectiveTransform(ipts, M);
end
%}

%{
% same number of points per view
function [opts, ipts, imgSize] = getPointsRandom(nPerView, nView)
    opts = rand([nPerView,3,nView], 'single');
    opts(:,3,:) = 0;    % planar rig
    opts = num2cell(reshape(num2cell(opts, 2), [nPerView nView]), 1);

    ipts = rand([nPerView,2,nView], 'single') * 100;
    ipts = num2cell(reshape(num2cell(ipts, 2), [nPerView nView]), 1);
    imgSize = [100 100];
end

% different number of points per view
function [opts, ipts, imgSize] = getPointsRandom2(nPerView, nView)
    opts = cell(1,nView);
    ipts = cell(1,nView);
    for v=1:nView
        N = randi([4 nPerView]);
        opts{v} = num2cell(rand(N,3,'single'), 2);
        ipts{v} = num2cell(rand(N,2,'single')*100, 2);
    end
    imgSize = [100 100];
end
%}
