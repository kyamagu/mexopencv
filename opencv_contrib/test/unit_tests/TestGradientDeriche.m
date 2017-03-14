classdef TestGradientDeriche
    %TestGradientDeriche

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            for i=1:2
                if i==2
                    img = cv.cvtColor(img, 'RGB2GRAY');
                end

                Gx = cv.GradientDeriche(img, 'X');
                Gy = cv.GradientDeriche(img, 'Y');
                G = hypot(Gx,Gy);

                validateattributes(Gx, {'numeric'}, {'real', 'size',size(img)});
                validateattributes(Gy, {'numeric'}, {'real', 'size',size(img)});
            end
        end

        function test_error_argnum
            try
                cv.GradientDeriche();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
