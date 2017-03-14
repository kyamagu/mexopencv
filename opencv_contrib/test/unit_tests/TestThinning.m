classdef TestThinning
    %TestThinning

    methods (Static)
        function test_1
            bw = cv.imread(fullfile(mexopencv.root(),'test','bw.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            out = cv.thinning(bw, 'ThinningType','ZhangSuen');
            validateattributes(out, {class(bw)}, {'size',size(bw)});
        end

        function test_error_argnum
            try
                cv.thinning();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
