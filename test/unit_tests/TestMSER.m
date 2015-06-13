classdef TestMSER
    %TestMSER
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            obj = cv.MSER();
            chains = obj.detectRegions(TestMSER.img);
        end
        
        function test_error_1
            try
                cv.MSER('foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

