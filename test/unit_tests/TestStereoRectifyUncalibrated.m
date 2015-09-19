classdef TestStereoRectifyUncalibrated
    %TestStereoRectifyUncalibrated

    methods (Static)
        function test_1
            [~, ipts1, ipts2, imgSize] = getPointsPair();
            F = cv.findFundamentalMat(ipts1, ipts2);
            [H1, H2, success] = cv.stereoRectifyUncalibrated(...
                ipts1, ipts2, F, imgSize);
            validateattributes(success, {'logical'}, {'scalar'});
            if success
                validateattributes(H1, {'numeric'}, {'size',[3 3]});
                validateattributes(H2, {'numeric'}, {'size',[3 3]});
            end
        end

        function test_error_1
            try
                cv.stereoRectifyUncalibrated();
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
