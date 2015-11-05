classdef TestFloodFill
    %TestFloodFill
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_gray
            im = cv.imread(TestFloodFill.img, 'Grayscale',true);
            seed = [100,100];
            value = 255;
            [rslt,rect,a] = cv.floodFill(im, seed, value);
            validateattributes(rslt, {class(im)}, {'size',size(im)});
            validateattributes(rect, {'numeric'}, {'vector', 'numel',4});
            validateattributes(a, {'numeric'}, {'scalar', 'nonnegative'});
        end

        function test_color
            im = imread(TestFloodFill.img);
            seed = [100,100];
            value = [255 0 0];
            [rslt,rect,a] = cv.floodFill(im, seed, value);
        end

        function test_options
            im = imread(TestFloodFill.img);
            seed = [100,100];
            value = [255 0 0];
            rslt = cv.floodFill(im, seed, value, 'FixedRange',false, ...
                'LoDiff',[0 0 0], 'UpDiff',[0 0 0], 'Connectivity',4);
        end

        function test_mask
            im = cv.imread(TestFloodFill.img, 'Grayscale',true);
            mask = zeros(size(im)+2, 'uint8');
            seed = [100,100];
            value = 255;
            [rslt,rect,a,mask2] = cv.floodFill(im, seed, value, ...
                'Mask',mask, 'MaskOnly',false, 'MaskFillValue',255);
            validateattributes(mask2, {class(mask)}, {'size',size(mask)});
        end

        function test_types
            im = cv.copyMakeBorder(magic(3), [1 1 1 1], ...
                'BorderType','Constant', 'Value',128);
            types = {'uint8', 'int32', 'single'};
            for i=1:numel(types)
                result = cv.floodFill(cast(im,types{i}), [2 2], 255);
                validateattributes(result, {types{i}}, {'size',size(im)});
            end
        end

        function test_error_1
            try
                cv.floodFill();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
