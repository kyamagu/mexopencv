classdef TestBm3dDenoising
    %TestBm3dDenoising

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','cat.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);
            out = cv.bm3dDenoising(img, 'H',10);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.bm3dDenoising();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
