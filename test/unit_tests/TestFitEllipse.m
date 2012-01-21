classdef TestFitEllipse
    %TestFitEllipse
    properties (Constant)
        points = mat2cell(255*randn(50,2),ones(50,1),2)';
    end
    
    methods (Static)
        function test_1
            rct = cv.fitEllipse(TestFitEllipse.points);
        end
        
        function test_error_1
            try
                cv.fitEllipse();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

