classdef TestColorChange
    %TestColorChange

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            mask = zeros(size(img,1), size(img,2), 'uint8');
            mask(250:end, 320:end) = 255;

            out = cv.colorChange(img, mask, 'R',2.5, 'G',2.5, 'B',1.0);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.colorChange();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
