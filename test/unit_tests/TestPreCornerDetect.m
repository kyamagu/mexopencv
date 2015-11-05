classdef TestPreCornerDetect
    %TestPreCornerDetect
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestPreCornerDetect.im, 'Grayscale',true);
            result = cv.preCornerDetect(img);
            validateattributes(result, {'single'}, ...
                {'real', '2d', 'size',size(img)});
        end

        function test_2
            img = cv.imread(TestPreCornerDetect.im, 'Grayscale',true);
            result = cv.preCornerDetect(double(img)/255);
            validateattributes(result, {'single'}, ...
                {'real', '2d', 'size',size(img)});
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
