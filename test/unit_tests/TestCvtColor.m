classdef TestCvtColor
    %TestCvtColor
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestCvtColor.im);
            [h,w,~] = size(img);
            result = cv.cvtColor(img, 'RGB2GRAY');
            validateattributes(result, {class(img)}, {'2d', 'size',[h,w]});
        end

        function test_2
            img = imread(TestCvtColor.im);
            result = cv.cvtColor(img, 'RGB2GRAY', 'DstCn',0);
        end

        function test_3
            img = cv.imread(TestCvtColor.im, 'Grayscale',true);
            result = cv.cvtColor(img, 'GRAY2RGB');
            validateattributes(result, {class(img)}, ...
                {'3d', 'size',[NaN NaN 3]});
        end

        function test_4
            codes = {'RGB2BGR', 'RGB2XYZ', 'RGB2YCrCb', 'RGB2YUV', ...
                'RGB2HSV', 'RGB2HLS', 'RGB2Lab', 'RGB2Luv'};
            img = imread(TestCvtColor.im);
            [h,w,~] = size(img);
            for i=1:numel(codes)
                result = cv.cvtColor(img, codes{i});
                validateattributes(result, {class(img)}, ...
                    {'3d', 'size',[h,w,3]});
            end
        end

        function test_error_1
            try
                cv.cvtColor();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
