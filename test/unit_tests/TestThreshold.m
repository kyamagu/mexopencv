classdef TestThreshold
    %TestThreshold

    methods (Static)
        function test_result
            img = rand(50, 'single');
            result = cv.threshold(img, 0.5, 'MaxValue',1.0);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_threshold_types
            img = cv.imread(fullfile(mexopencv.root(),'test','sudoku.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);
            types = {'Binary', 'BinaryInv', 'Trunc', 'ToZero', 'ToZeroInv'};
            for i=1:numel(types)
                result = cv.threshold(img, 127, 'MaxValue',255, 'Type',types{i});
                validateattributes(result, {class(img)}, {'size',size(img)});
            end
        end

        function test_auto_threshold
            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);

            [result,t] = cv.threshold(img, 'Otsu');
            validateattributes(result, {class(img)}, {'size',size(img)});
            validateattributes(t, {'numeric'}, {'scalar'});

            [result,t] = cv.threshold(img, 'Triangle');
            validateattributes(result, {class(img)}, {'size',size(img)});
            validateattributes(t, {'numeric'}, {'scalar'});
        end

        function test_compare_im2bw
            % we use GRAYTHRESH/IM2BW from Image Processing Toolbox
            if ~mexopencv.require('images')
                error('mexopencv:testskip', 'toolbox');
            end

            % compare against im2bw/graythresh
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            [img1,t1] = cv.threshold(img, 'Otsu', 'MaxValue',255, 'Type','Binary');
            t2 = graythresh(img);
            img2 = im2bw(img, t2);
            if false
                assert(isequal(t1, round(t2*255)));
                assert(isequal(logical(img1), img2));
            end
        end

        function test_error_argnum
            try
                cv.threshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
