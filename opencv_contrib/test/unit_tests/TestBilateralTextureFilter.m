classdef TestBilateralTextureFilter
    %TestBilateralTextureFilter

    methods (Static)
        function test_simple
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            out = cv.bilateralTextureFilter(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.bilateralTextureFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
