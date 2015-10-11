classdef TestBoxFilter
    %TestBoxFilter
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
    end

    methods (Static)
        function test_1
            out = cv.boxFilter(TestBoxFilter.img);
            validateattributes(out, {class(TestBoxFilter.img)}, ...
                {'size',size(TestBoxFilter.img)});
        end

        function test_2
            out = cv.boxFilter(TestBoxFilter.img, 'DDepth',-1, ...
                'KSize',[5 5], 'Anchor',[-1 -1], 'BorderType','Default');
            validateattributes(out, {class(TestBoxFilter.img)}, ...
                {'size',size(TestBoxFilter.img)});
        end

        function test_3
            out = cv.boxFilter(TestBoxFilter.img, 'Normalize',false);
            validateattributes(out, {class(TestBoxFilter.img)}, ...
                {'size',size(TestBoxFilter.img)});
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
