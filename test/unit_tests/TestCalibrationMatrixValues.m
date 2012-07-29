classdef TestCalibrationMatrixValues
    %TestCalibrationMatrixValues
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            A = [1,0,.5; 0,1,.5; 0,0,1];
            S = cv.calibrationMatrixValues(A,[640,480],4,3);
        end
        
        function test_error_1
            try
                cv.calibrationMatrixValues();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

