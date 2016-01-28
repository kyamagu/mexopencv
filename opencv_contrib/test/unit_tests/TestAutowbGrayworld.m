classdef TestAutowbGrayworld
    %TestAutowbGrayworld
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestAutowbGrayworld.im, 'Color',true);
            dst = cv.autowbGrayworld(img, 'Thresh',0.5);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.autowbGrayworld();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
