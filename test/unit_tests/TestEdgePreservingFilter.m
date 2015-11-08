classdef TestEdgePreservingFilter
    %TestEdgePreservingFilter

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            out = cv.edgePreservingFilter(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            out = cv.edgePreservingFilter(img, 'Filter','Recursive', ...
                'SigmaS',60 ,'SigmaR',0.4);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.edgePreservingFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
