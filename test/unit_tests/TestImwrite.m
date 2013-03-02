classdef TestImwrite
    %TestImwrite
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
        filename = [tempname '.jpg'];
    end
    
    methods (Static)
        function test_1
            cv.imwrite(TestImwrite.filename,TestImwrite.im);
            if exist(TestImwrite.filename,'file')
                delete(TestImwrite.filename);
            end
        end
        
        function test_error_1
            try
                cv.imwrite();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        function test_error_2
            try
                cv.imwrite(TestImwrite.filename,TestImwrite.im,'JpegQuality',-1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

