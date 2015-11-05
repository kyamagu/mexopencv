classdef TestBoxFilter
    %TestBoxFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestBoxFilter.im);
            out = cv.boxFilter(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestBoxFilter.im);
            out = cv.boxFilter(img, 'DDepth',-1, ...
                'KSize',[5 5], 'Anchor',[-1 -1], 'BorderType','Default');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_3
            img = imread(TestBoxFilter.im);
            out = cv.boxFilter(img, 'Normalize',false);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.boxFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
