classdef TestFitLine
    %TestFitLine
    properties (Constant)
        points = mat2cell([1:50;ones(1,50)]'+10*randn(50,2),ones(50,1),2)';
    end
    
    methods (Static)
        function test_1
            rct = cv.fitLine(TestFitLine.points);
        end
        
        function test_error_1
            try
                cv.fitLine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

