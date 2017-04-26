classdef TestCalcOpticalFlowPyrLK
    %TestCalcOpticalFlowPyrLK

    properties (Constant)
        img1 = fullfile(mexopencv.root(),'test','RubberWhale1.png');
        img2 = fullfile(mexopencv.root(),'test','RubberWhale2.png');
    end

    methods (Static)
        function test_1
            im1 = 255*uint8([...
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
            im2 = circshift(im1, [0 1]);
            pts = cv.calcOpticalFlowPyrLK(im1, im2, {[3,3]});
        end

        function test_images
            prevImg = cv.imread(TestCalcOpticalFlowPyrLK.img1, ...
                'Grayscale',true, 'ReduceScale',2);
            nextImg = cv.imread(TestCalcOpticalFlowPyrLK.img2, ...
                'Grayscale',true, 'ReduceScale',2);
            prevPts = cv.goodFeaturesToTrack(prevImg, 'MaxCorners',200);
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

        function test_pyramids
            %TODO: https://github.com/opencv/opencv/issues/8268
            % Failed assertion in calcOpticalFlowPyrLK (near locateROI).
            % The function expects pyramids input to be a submatrix of a
            % larger matrix (original image), but the ROI information is lost
            % when Mat is converted to mxArray and back (a full copy is made)
            if true
                error('mexopencv:testskip', 'todo');
            end

            prevImg = cv.imread(TestCalcOpticalFlowPyrLK.img1, ...
                'Grayscale',true, 'ReduceScale',2);
            nextImg = cv.imread(TestCalcOpticalFlowPyrLK.img2, ...
                'Grayscale',true, 'ReduceScale',2);
            prevPts = cv.goodFeaturesToTrack(prevImg, 'MaxCorners',200);
            prevPyr = cv.buildOpticalFlowPyramid(prevImg);
            nextPyr = cv.buildOpticalFlowPyramid(nextImg);
            nextPts = cv.calcOpticalFlowPyrLK(prevPyr, nextPyr, prevPts);
            validateattributes(nextPts, {'cell'}, ...
                {'vector', 'numel',numel(prevPts)});
        end

        function test_error_argnum
            try
                cv.calcOpticalFlowPyrLK();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
