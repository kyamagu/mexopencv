classdef TestCvtColor
    %TestCvtColor
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_1
            [h,w,~] = size(TestCvtColor.img);
            result = cv.cvtColor(TestCvtColor.img, 'RGB2GRAY');
            validateattributes(result, {class(TestCvtColor.img)}, ...
                {'2d', 'size',[h,w]});
        end

        function test_2
            result = cv.cvtColor(TestCvtColor.img, 'RGB2GRAY', 'DstCn',0);
        end

        function test_3
            result = cv.cvtColor(rgb2gray(TestCvtColor.img), 'GRAY2RGB');
            validateattributes(result, {class(TestCvtColor.img)}, ...
                {'3d', 'size',[NaN NaN 3]});
        end

        function test_4
            codes = {'RGB2BGR', 'RGB2XYZ', 'RGB2YCrCb', 'RGB2YUV', ...
                'RGB2HSV', 'RGB2HLS', 'RGB2Lab', 'RGB2Luv'};
            [h,w,~] = size(TestCvtColor.img);
            for i=1:numel(codes)
                result = cv.cvtColor(TestCvtColor.img, codes{i});
                validateattributes(result, {class(TestCvtColor.img)}, ...
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
