classdef TestCornerEigenValsAndVecs
    %TestCornerEigenValsAndVecs
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end

    methods (Static)
        function test_8bit
            result = cv.cornerEigenValsAndVecs(TestCornerEigenValsAndVecs.img);
            validateattributes(result, {'single'}, {'ndims',3, ...
                'size',[size(TestCornerEigenValsAndVecs.img) 6]});
        end

        function test_float
            result = cv.cornerEigenValsAndVecs(...
                im2single(TestCornerEigenValsAndVecs.img));
            validateattributes(result, {'single'}, {'ndims',3, ...
                'size',[size(TestCornerEigenValsAndVecs.img) 6]});
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
