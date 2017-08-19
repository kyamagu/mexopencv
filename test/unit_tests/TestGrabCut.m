classdef TestGrabCut
    %TestGrabCut

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_init_rect
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
            sz = size(img);
            bbox = [75 50 100 175]; % [x y w h]
            [res, bgd, fgd] = cv.grabCut(img, bbox, 'Mode','InitWithRect');
            validateattributes(res, {'uint8'}, {'size',sz(1:2), '<=',3});
            validateattributes(bgd, {'double'}, {'vector', 'numel',65});
            validateattributes(fgd, {'double'}, {'vector', 'numel',65});
        end

        function test_init_mask
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
            sz = size(img);
            bbox = [75 50 100 175];
            mask = zeros(sz(1:2),'uint8');
            mask(:) = 0;
            mask = cv.rectangle(mask, bbox, 'Color',3, 'Thickness','Filled');
            [res, bgd, fgd] = cv.grabCut(img, mask, 'Mode','InitWithMask');
            validateattributes(res, {'uint8'}, {'size',sz(1:2), '<=',3});
            validateattributes(bgd, {'double'}, {'vector', 'numel',65});
            validateattributes(fgd, {'double'}, {'vector', 'numel',65});
        end

        function test_eval
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
            bbox = [75 50 100 175];
            [res, bgd, fgd] = cv.grabCut(img, bbox, 'Mode','InitWithRect');
            for i=1:2
                [res, bgd, fgd] = cv.grabCut(img, res, 'Mode','Eval', ...
                    'BgdModel',bgd, 'FgdModel',fgd, 'IterCount',1);
            end
        end

        function test_error_argnum
            try
                cv.grabCut();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_arg
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_unrecognized_option
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_option_value_1
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
            mask = zeros(size(img,1),size(img,2),'uint8');
            try
                cv.grabCut(img, mask, 'Mode','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_option_value_2
            img = cv.imread(TestGrabCut.im, 'ReduceScale',2);
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
