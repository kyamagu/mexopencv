classdef TestSURF
    %TestSURF
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            result = cv.SURF(TestSURF.img);
        end
        
        function test_2
            [kpts,desc] = cv.SURF(TestSURF.img);
        end
        
        function test_error_1
            try
                cv.SURF();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

