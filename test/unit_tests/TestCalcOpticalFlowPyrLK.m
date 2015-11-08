classdef TestCalcOpticalFlowPyrLK
    %TestCalcOpticalFlowPyrLK
    properties (Constant)
        im = 255*uint8([...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 0 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
        ]);
    end

    methods (Static)
        function test_1
            im1 = TestCalcOpticalFlowPyrLK.im;
            im2 = circshift(im1, [0 1]);
            pts = cv.calcOpticalFlowPyrLK(im1, im2, {[3,3]});
        end

        function test_2
            prevImg = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale1.png'), 'Grayscale',true);
            nextImg = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale2.png'), 'Grayscale',true);
            prevPts = cv.goodFeaturesToTrack(prevImg);
            [nextPts,status,err] = cv.calcOpticalFlowPyrLK(prevImg, nextImg, prevPts);
            validateattributes(nextPts, {'cell'}, ...
                {'vector', 'numel',numel(prevPts)});
            cellfun(@(pt) validateattributes(pt, {'numeric'}, ...
                {'vector', 'numel',2}), nextPts);
            validateattributes(status, {'uint8'}, ...
                {'vector', 'binary', 'numel',numel(nextPts)});
            validateattributes(err, {'single'}, ...
                {'vector', 'real', 'numel',numel(nextPts)});
        end

        function test_3
            prevImg = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale1.png'), 'Grayscale',true);
            nextImg = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale2.png'), 'Grayscale',true);
            prevPts = cv.goodFeaturesToTrack(prevImg);
            prevPyr = cv.buildOpticalFlowPyramid(prevImg);
            nextPyr = cv.buildOpticalFlowPyramid(nextImg);
            nextPts = cv.calcOpticalFlowPyrLK(prevImg, nextImg, prevPts);
            validateattributes(nextPts, {'cell'}, ...
                {'vector', 'numel',numel(prevPts)});
        end

        function test_error_1
            try
                cv.calcOpticalFlowPyrLK();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
