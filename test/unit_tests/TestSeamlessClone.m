classdef TestSeamlessClone
    %TestSeamlessClone

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','balloon.jpg'));
            dst = img;
            mask = zeros(size(img,1), size(img,2), 'uint8');
            mask(20:120, 5:100) = 255;
            p = [400 200];

            out = cv.seamlessClone(img, dst, mask, p, 'Method','NormalClone');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.seamlessClone();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
