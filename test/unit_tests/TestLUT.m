classdef TestLUT
    %TestLUT

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), ...
                'ReduceScale',2);
            lut = uint8(255:-1:0);
            out = cv.LUT(img, lut);
            validateattributes(out, {class(lut)}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), ...
                'ReduceScale',2);
            lut = cat(3, linspace(1,0,256), linspace(0,1,256), linspace(0,1,256));
            out = cv.LUT(img, lut);
            validateattributes(out, {class(lut)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.LUT();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
