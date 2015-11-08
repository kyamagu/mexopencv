classdef TestIlluminationChange
    %TestIlluminationChange

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            mask = zeros(size(img,1), size(img,2), 'uint8');
            mask(200:275, 350:440) = 255;

            out = cv.illuminationChange(img, mask, 'Alpha',0.1, 'Beta',0.2);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.illuminationChange();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
