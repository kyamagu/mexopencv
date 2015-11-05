classdef TestGrabCut
    %TestGrabCut
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_init_rect
            img = imread(TestGrabCut.im);
            sz = size(img);
            bbox = [100,100,280,320]; % [x y w h]
            [res, bgd, fgd] = cv.grabCut(img, bbox, 'Mode','InitWithRect');
            validateattributes(res, {'uint8'}, {'size',sz(1:2), '<=',3});
            validateattributes(bgd, {'double'}, {'vector', 'numel',65});
            validateattributes(fgd, {'double'}, {'vector', 'numel',65});
        end

        function test_init_mask
            img = imread(TestGrabCut.im);
            sz = size(img);
            bbox = [100,100,200,320]; % [y x w h]
            mask = zeros(sz(1:2),'uint8');
            mask(:) = 0;
            mask(bbox(2):(bbox(2)+bbox(4)-1),bbox(1):(bbox(1)+bbox(3)-1)) = 3;
            [res, bgd, fgd] = cv.grabCut(img, mask, 'Mode','InitWithMask');
            validateattributes(res, {'uint8'}, {'size',sz(1:2), '<=',3});
            validateattributes(bgd, {'double'}, {'vector', 'numel',65});
            validateattributes(fgd, {'double'}, {'vector', 'numel',65});
        end

        function test_eval
            img = imread(TestGrabCut.im);
            bbox = [100,100,280,320];
            [res, bgd, fgd] = cv.grabCut(img, bbox, 'Mode','InitWithRect');
            for i=1:2
                [res, bgd, fgd] = cv.grabCut(img, res, 'Mode','Eval', ...
                    'BgdModel',bgd, 'FgdModel',fgd, 'IterCount',1);
            end
        end

        function test_error_1
            try
                cv.grabCut();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_2
            img = imread(TestGrabCut.im);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_3
            img = imread(TestGrabCut.im);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'foo', 'bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_4
            img = imread(TestGrabCut.im);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'Mode','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_5
            img = imread(TestGrabCut.im);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'IterCount','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

    end
end
