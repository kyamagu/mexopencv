classdef TestTextureFlattening
    %TestTextureFlattening

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            mask = zeros(size(img,1), size(img,2), 'uint8');
            mask(80:460, 100:340) = 255;

            out = cv.textureFlattening(img, mask, 'KernelSize',3, ...
                'LowThreshold',30, 'HighThreshold',45);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.textureFlattening();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
