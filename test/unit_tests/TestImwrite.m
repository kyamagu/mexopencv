classdef TestImwrite
    %TestImwrite
    properties (Constant)
    	im = im2uint8(randn(32,32,3));
        path = fileparts(fileparts(mfilename('fullpath')))
        filename = [TestImwrite.path,filesep,'foo.jpg'];
    end
    
    methods (Static)
        function test_1
            imwrite(TestImwrite.filename,TestImwrite.im);
            if exist(TestImwrite.filename,'file')
            	delete(TestImwrite.filename);
            end
        end
        
        function test_error_1
            try
                imwrite();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        function test_error_2
            try
                imwrite(TestImwrite.filename,TestImwrite.im,'JpegQuality',-1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

