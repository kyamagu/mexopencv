classdef TestSepFilter2D
    %TestSepFilter2D
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
            kernel = [1 1 1;];
            reference = filter2(kernel,TestSepFilter2D.img);
            result = cv.sepFilter2D(TestSepFilter2D.img,kernel,1);
            assert(all(abs(reference(:) - result(:)) < 1e-15));
        end
        
        function test_error_1
            try
                cv.sepFilter2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

