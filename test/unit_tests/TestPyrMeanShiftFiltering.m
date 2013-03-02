classdef TestPyrMeanShiftFiltering
    %TestPyrMeanShiftFiltering
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            result = cv.pyrMeanShiftFiltering(TestPyrMeanShiftFiltering.img);
        end
        
        function test_2
            result = cv.pyrMeanShiftFiltering(TestPyrMeanShiftFiltering.img, 'SP', 7);
        end
        
        function test_error_1
            try
                cv.pyrMeanShiftFiltering();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

