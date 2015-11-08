classdef TestStylization
    %TestStylization

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            out = cv.stylization(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            out = cv.stylization(img, 'SigmaS',60 ,'SigmaR',0.45);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.stylization();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
