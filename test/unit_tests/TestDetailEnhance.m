classdef TestDetailEnhance
    %TestDetailEnhance

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'ReduceScale',2);
            out = cv.detailEnhance(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'ReduceScale',2);
            out = cv.detailEnhance(img, 'SigmaS',10 ,'SigmaR',0.15);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.detailEnhance();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
