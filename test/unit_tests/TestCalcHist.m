classdef TestCalcHist
    %TestCalcHist
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestCalcHist.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
    	function test_1
            edges = {linspace(0,256,32+1),linspace(0,256,32+1)};
            H = cv.calcHist(TestCalcHist.img(:,:,1:2),edges);
    	end
    	
        function test_error_1
            try
                cv.calcHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

