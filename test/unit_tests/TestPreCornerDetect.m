classdef TestPreCornerDetect
    %TestPreCornerDetect
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end

    methods (Static)
        function test_1
            result = cv.preCornerDetect(TestPreCornerDetect.img);
            validateattributes(result, {'single'}, {'real', '2d', ...
                'size',size(TestPreCornerDetect.img)});
        end

        function test_2
            result = cv.preCornerDetect(im2double(TestPreCornerDetect.img));
            validateattributes(result, {'single'}, {'real', '2d', ...
                'size',size(TestPreCornerDetect.img)});
        end

        function test_error_1
            try
                cv.preCornerDetect();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
