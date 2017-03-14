classdef TestSimpleWB
    %TestSimpleWB

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_8u
            % rgb
            img = cv.imread(TestSimpleWB.im, 'Color',true, 'ReduceScale',2);
            wb = cv.SimpleWB();
            out = wb.balanceWhite(img);
            validateattributes(out, {class(img)}, {'size',size(img)});

            % gray
            img = cv.cvtColor(img, 'RGB2GRAY');
            out = wb.balanceWhite(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_32f
            img = cv.imread(TestSimpleWB.im, 'Color',true, 'ReduceScale',2);
            img = single(img) / 255;

            wb = cv.SimpleWB();
            wb.InputMin = 0.0;
            wb.InputMax = 1.0;
            wb.OutputMin = 0.0;
            wb.OutputMax = 1.0;
            out = wb.balanceWhite(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end
    end

end
