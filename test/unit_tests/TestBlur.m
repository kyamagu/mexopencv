classdef TestBlur
    %TestBlur
    properties (Constant)
        img = [...
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
        ];
    end

    methods (Static)
        function test_1
            result = cv.blur(TestBlur.img);
            validateattributes(result, {class(TestBlur.img)}, ...
                {'size',size(TestBlur.img)});
        end

        function test_2
            result = cv.blur(TestBlur.img, 'KSize', [3,7]);
            validateattributes(result, {class(TestBlur.img)}, ...
                {'size',size(TestBlur.img)});
        end

        function test_3
            result = cv.blur(TestBlur.img, 'Anchor', [0,1]);
            validateattributes(result, {class(TestBlur.img)}, ...
                {'size',size(TestBlur.img)});
        end

        function test_4
            result = cv.blur(TestBlur.img, 'BorderType', 'Constant');
            validateattributes(result, {class(TestBlur.img)}, ...
                {'size',size(TestBlur.img)});
        end

        function test_5
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.blur(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.blur();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
