classdef TestWarpAffine
    %TestWarpAffine
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestWarpAffine.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
    	function test_1
    		x0 = [0,0;1,0;1,1];
            M = getAffineTransform(x0,x0); % identity transform
            dst = warpAffine(TestWarpAffine.img,M);
            assert(all(TestWarpAffine.img(:)==dst(:)));
    	end
    	
        function test_error_1
            try
                warpAffine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

