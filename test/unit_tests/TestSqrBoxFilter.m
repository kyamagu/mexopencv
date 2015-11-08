classdef TestSqrBoxFilter
    %TestSqrBoxFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestSqrBoxFilter.im);
            out = cv.sqrBoxFilter(img);
            validateattributes(out, {'single'}, {'size',size(img)});
        end

        function test_2
            img = imread(TestSqrBoxFilter.im);
            out = cv.sqrBoxFilter(img, 'DDepth','double', ...
                'KSize',[5 5], 'Anchor',[-1 -1], 'BorderType','Default');
            validateattributes(out, {'double'}, {'size',size(img)});
        end

        function test_3
            img = imread(TestSqrBoxFilter.im);
            out = cv.sqrBoxFilter(img, 'Normalize',false);
            validateattributes(out, {'single'}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.sqrBoxFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
