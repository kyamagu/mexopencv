classdef TestResize
    %TestResize
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestResize.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
    	function test_1
            ref = TestResize.img(1:2:end,1:2:end,:);
            dst = resize(TestResize.img,0.5,'Interpolation','Nearest');
            assert(all(ref(:)==dst(:)));
    	end
    	
    	function test_2
    		ref = TestResize.img(1:2:end,1:2:end,:);
            dst = resize(TestResize.img,[256,256],'Interpolation','Nearest');
            assert(all(abs(ref(:)-dst(:))<1e-5));
    	end
    	
        function test_error_1
            try
                resize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

