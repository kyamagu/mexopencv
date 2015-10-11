classdef TestMedianBlur
    %TestMedianBlur
    properties (Constant)
        img = uint8([...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
        ]);
    end

    methods (Static)
        function test_1
            result = cv.medianBlur(TestMedianBlur.img);
            validateattributes(result, {class(TestMedianBlur.img)}, ...
                {'size',size(TestMedianBlur.img)});
        end

        function test_2
            result = cv.medianBlur(TestMedianBlur.img, 'KSize',7);
            validateattributes(result, {class(TestMedianBlur.img)}, ...
                {'size',size(TestMedianBlur.img)});
        end

        function test_3
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.medianBlur(img, 'KSize',11);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.medianBlur();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
