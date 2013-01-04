classdef TestCalcBackProject
    %TestCalcBackProject
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            im = TestCalcBackProject.img;
            edges = {linspace(0,256,32+1),linspace(0,256,32+1)};
            H = cv.calcHist(im(:,:,1:2),edges);
            b = cv.calcBackProject(im(:,:,1:2),H,edges);
        end
        
        function test_error_1
            try
                cv.calcBackProject();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

