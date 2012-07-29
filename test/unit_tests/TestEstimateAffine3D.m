classdef TestEstimateAffine3D
    %TestEstimateAffine3D
    properties (Constant)
    end
    
    methods (Static)        
        function test_error_1
            try
                cv.estimateAffine3D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

