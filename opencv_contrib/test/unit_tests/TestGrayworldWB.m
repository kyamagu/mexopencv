classdef TestGrayworldWB
    %TestGrayworldWB

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'Color',true, 'ReduceScale',2);
            wb = cv.GrayworldWB();
            wb.SaturationThreshold = 0.5;
            out = wb.balanceWhite(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end
    end

end
