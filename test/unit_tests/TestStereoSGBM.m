classdef TestStereoSGBM
    %TestStereoSGBM
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            bm = cv.StereoSGBM();
        end
        
        function test_2
            bm = cv.StereoSGBM('MinDisparity',0);
        end
    end
    
end

