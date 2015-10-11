classdef TestDetailEnhance
    %TestDetailEnhance
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
    end

    methods (Static)
        function test_1
            img = TestDetailEnhance.im;
            out = cv.detailEnhance(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = TestDetailEnhance.im;
            out = cv.detailEnhance(img, 'SigmaS',10 ,'SigmaR',0.15);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.detailEnhance();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
