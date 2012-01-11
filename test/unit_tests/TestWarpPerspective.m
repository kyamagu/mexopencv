classdef TestWarpPerspective
    %TestWarpPerspective
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestWarpPerspective.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
    	function test_1
            M = eye(3); % identity transform
            dst = warpPerspective(TestWarpPerspective.img,M);
            assert(all(TestWarpPerspective.img(:)==dst(:)));
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

