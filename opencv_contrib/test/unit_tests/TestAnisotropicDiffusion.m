classdef TestAnisotropicDiffusion
    %TestAnisotropicDiffusion

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), ...
                'Color',true, 'ReduceScale',2);
            out = cv.anisotropicDiffusion(img, ...
                'Alpha',1.0, 'K',0.02, 'Iterations',5);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.anisotropicDiffusion();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
