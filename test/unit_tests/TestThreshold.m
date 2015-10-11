classdef TestThreshold
    %TestThreshold

    methods (Static)
        function test_result
            img = rand(100, 'single');
            result = cv.threshold(img, 0.5);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_methods
            img = randi(255, [100 100], 'uint8');
            types = {'Binary', 'BinaryInv', 'Trunc', 'ToZero', 'ToZeroInv'};
            for i=1:numel(types)
                result = cv.threshold(img, 127, ...
                    'MaxValue',255, 'Method',types{i});
            end
        end

        function test_auto_threshold
            img = rgb2gray(imread(fullfile(mexopencv.root(),'test','fruits.jpg')));
            [result,t] = cv.threshold(img, 'Otsu', ...
                'Method','Binary', 'MaxValue',255);
            [result,t] = cv.threshold(img, 'Triangle', ...
                'Method','Binary', 'MaxValue',255);
            validateattributes(t, {'numeric'}, {'scalar'});
        end

        function test_compare_im2bw
            % image processing toolbox
            if mexopencv.isOctave()
                img_tlbx = 'image';
            else
                img_tlbx = 'image_toolbox';
            end
            if ~license('test', img_tlbx), return; end
            % compare against im2bw
            img = imread('left01.jpg');
            [img1,t1] = cv.threshold(img, 'Otsu', ...
                'MaxValue',255, 'Method','Binary');
            t2 = graythresh(img);
            img2 = im2bw(img, t2);
            %assert(isequal(t1, round(t2*255)));
            %assert(isequal(img1,img2));
        end

        function test_error_1
            try
                cv.threshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
