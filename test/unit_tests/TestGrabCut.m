classdef TestGrabCut
    %TestGrabCut
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_init_rect
            sz = size(TestGrabCut.img);
            bbox = [100,100,280,320]; % [x y w h]
            [res, bgd, fgd] = cv.grabCut(TestGrabCut.img, bbox, 'Mode','InitWithRect');
            validateattributes(res, {'uint8'}, {'size',sz(1:2), '<=',3});
            validateattributes(bgd, {'double'}, {'vector', 'numel',65});
            validateattributes(fgd, {'double'}, {'vector', 'numel',65});
        end

        function test_init_mask
            sz = size(TestGrabCut.img);
            bbox = [100,100,200,320]; % [y x w h]
            mask = zeros(sz(1:2),'uint8');
            mask(:) = 0;
            mask(bbox(2):(bbox(2)+bbox(4)-1),bbox(1):(bbox(1)+bbox(3)-1)) = 3;
            [res, bgd, fgd] = cv.grabCut(TestGrabCut.img, mask, 'Mode','InitWithMask');
            validateattributes(res, {'uint8'}, {'size',sz(1:2), '<=',3});
            validateattributes(bgd, {'double'}, {'vector', 'numel',65});
            validateattributes(fgd, {'double'}, {'vector', 'numel',65});
        end

        function test_eval
            bbox = [100,100,280,320];
            [res, bgd, fgd] = cv.grabCut(TestGrabCut.img, bbox, 'Mode','InitWithRect');
            for i=1:2
                [res, bgd, fgd] = cv.grabCut(TestGrabCut.img, res, 'Mode','Eval', ...
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
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img, mask, 'foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_3
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img, mask, 'foo', 'bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_4
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img, mask, 'Mode','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_5
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img, mask, 'IterCount','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

    end
end
