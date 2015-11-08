classdef TestCornerEigenValsAndVecs
    %TestCornerEigenValsAndVecs
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_8bit
            img = cv.imread(TestCornerEigenValsAndVecs.im, 'Grayscale',true);
            result = cv.cornerEigenValsAndVecs(img);
            validateattributes(result, {'single'}, ...
                {'ndims',3, 'size',[size(img) 6]});
        end

        function test_float
            img = cv.imread(TestCornerEigenValsAndVecs.im, 'Grayscale',true);
            result = cv.cornerEigenValsAndVecs(single(img)/255);
            validateattributes(result, {'single'}, ...
                {'ndims',3, 'size',[size(img) 6]});
        end

        function test_error_1
            try
                cv.cornerEigenValsAndVecs();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
