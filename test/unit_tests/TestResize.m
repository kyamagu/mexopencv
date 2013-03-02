classdef TestResize
    %TestResize
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            im = TestResize.img;
            ref = im(1:2:end,1:2:end,:);
            dst = cv.resize(im,0.5,'Interpolation','Nearest');
            assert(all(ref(:)==dst(:)));
        end
        
        function test_2
            im = TestResize.img;
            ref = im(1:2:end,1:2:end,:);
            dst = cv.resize(im,[256,256],'Interpolation','Nearest');
            assert(all(abs(ref(:)-dst(:))<1e-5));
        end
        
        function test_error_1
            try
                cv.resize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

