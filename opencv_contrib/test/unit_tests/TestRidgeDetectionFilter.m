classdef TestRidgeDetectionFilter
    %TestRidgeDetectionFilter

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','blox.jpg'), ...
                'Grayscale',true);
            obj = cv.RidgeDetectionFilter('OutDType','uint8');
            out = obj.getRidgeFilteredImage(img);
            validateattributes(out, {'uint8'}, {'size',size(img)});
        end
    end

end
