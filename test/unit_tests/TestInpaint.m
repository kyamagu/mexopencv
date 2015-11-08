classdef TestInpaint
    %TestInpaint
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = randi(255, [10 10], 'uint8');
            mask = 255 * uint8([...
                0 0 0 0 0 0 0 0 0 0 ; ...
                0 0 0 0 0 0 0 0 0 0 ; ...
                0 0 0 0 0 0 0 0 0 0 ; ...
                0 0 0 1 1 1 0 0 0 0 ; ...
                0 0 0 1 1 1 0 0 0 0 ; ...
                0 0 0 1 1 1 0 0 0 0 ; ...
                0 0 0 0 0 0 0 0 0 0 ; ...
                0 0 0 0 0 0 0 0 0 0 ; ...
                0 0 0 0 0 0 0 0 0 0 ; ...
                0 0 0 0 0 0 0 0 0 0 ; ...
            ]);
            algs = {'NS', 'Telea'};
            for i=1:numel(algs)
                out = cv.inpaint(img, mask, 'Method',algs{i}, 'Radius',3.0);
                validateattributes(out, {class(img)}, {'size',size(img)});
            end
        end

        function test_gray
            img = cv.imread(TestInpaint.im, 'Grayscale',true);
            img = cv.resize(img, 0.4, 0.4);
            img(80:100, 80:100) = 0;

            mask = zeros(size(img), 'uint8');
            mask(80:100, 80:100) = 255;

            out = cv.inpaint(img, mask);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_rgb
            img = cv.imread(TestInpaint.im, 'Color',true);
            img = cv.resize(img, 0.4, 0.4);
            img(80:100, 80:100, :) = 0;

            mask = zeros(size(img,1), size(img,2), 'uint8');
            mask(80:100, 80:100) = 255;

            out = cv.inpaint(img, mask);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.inpaint();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
