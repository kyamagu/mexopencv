classdef TestDTFilter
    %TestDTFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestDTFilter.im);
            filt = cv.DTFilter(img, 'Mode','NC');
            dst = filt.filter(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestDTFilter.im);
            dst = cv.DTFilter.dtFilter(img, img, 'Mode','NC');
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end
    end

end
