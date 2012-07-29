classdef TestCompareHist
    %TestCompareHist
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            d = cv.compareHist(single(0:5),single(5:-1:0));
        end
        
        function test_error_1
            try
                cv.compareHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

