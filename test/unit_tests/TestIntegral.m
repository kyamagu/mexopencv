classdef TestIntegral
    %TestIntegral
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
            s = cv.integral(TestIntegral.img);
            validateattributes(s, {'int32'}, {'size',size(TestIntegral.img)+1});
        end

        function test_2
            [s,sqsum] = cv.integral(TestIntegral.img);
            validateattributes(s, {'int32'}, {'size',size(TestIntegral.img)+1});
            validateattributes(sqsum, {'double'}, {'size',size(TestIntegral.img)+1});
        end

        function test_3
            [s,sqsum,tilted] = cv.integral(TestIntegral.img);
            validateattributes(s, {'int32'}, {'size',size(TestIntegral.img)+1});
            validateattributes(sqsum, {'double'}, {'size',size(TestIntegral.img)+1});
            validateattributes(tilted, {'int32'}, {'size',size(TestIntegral.img)+1});
        end

        function test_4
            [s,sqsum,tilted] = cv.integral(TestIntegral.img, ...
                'SDepth','single', 'SQDepth','single');
            validateattributes(s, {'single'}, {'size',size(TestIntegral.img)+1});
            validateattributes(sqsum, {'single'}, {'size',size(TestIntegral.img)+1});
            validateattributes(tilted, {'single'}, {'size',size(TestIntegral.img)+1});
        end

        function test_error_1
            try
                cv.integral();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
