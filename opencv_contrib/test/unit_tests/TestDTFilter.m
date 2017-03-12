classdef TestDTFilter
    %TestDTFilter

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestDTFilter.im, 'Color',true, 'ReduceScale',2);
            filt = cv.DTFilter(img, 'Mode','NC');
            dst = filt.filter(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(TestDTFilter.im, 'Color',true, 'ReduceScale',2);
            dst = cv.DTFilter.dtFilter(img, img, 'Mode','NC');
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end
    end

end
