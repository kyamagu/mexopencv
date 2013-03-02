classdef TestORB
    %TestORB
    properties (Constant)
        img = rgb2gray(imread(fullfile(cv_root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            result = cv.ORB(TestORB.img);
        end
        
        function test_2
            [kpts,desc] = cv.ORB(TestORB.img);
        end
        
        function test_error_1
            try
                cv.ORB();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

