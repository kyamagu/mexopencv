classdef TestConvertTo
    %TestConvertTo

    methods (Static)
        function test_1
            A = magic(5);
            B = cv.convertTo(A, 'RType','single', 'Alpha',2, 'Beta',3);
            validateattributes(B, {'single'}, {'size',size(A)});
            assert(isequal(B, single(A*2+3)));
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            dst = cv.convertTo(img, 'RType','double', 'Alpha',1/255);
            validateattributes(dst, {'double'}, {'size',size(img)});
            assert(norm(dst(:) - double(img(:))/255) < 1e-6);
        end

        function test_error_argnum
            try
                cv.convertTo();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
