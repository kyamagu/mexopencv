classdef TestScharr
    %TestScharr

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','blox.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestScharr.im);
            result = cv.Scharr(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestScharr.im);
            result = cv.Scharr(img, ...
                'XOrder',0, 'YOrder',1, 'Scale',1, 'Delta',0, ...
                'BorderType','Default', 'DDepth','double');
            validateattributes(result, {'double'}, {'size',size(img)});
        end

        function test_3
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.Scharr(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.Scharr();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
