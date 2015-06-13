classdef TestInRange
    %TestInRange

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            bw = cv.inRange(img, 50, 200);
            assert(ismatrix(bw) && isequal(size(bw), size(img)));
            assert(islogical(bw));
        end

        function test_rgb_image
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            hsv = cv.cvtColor(img, 'RGB2HSV');
            bw = cv.inRange(hsv, [10 0 0], [165,255,255]);  % red hue
        end

        function test_grayscale_image
            % requires Image Processing Toolbox
            if ~license('test','image_toolbox'), return; end

            % compare against IM2BW
            % Note: lower bound in IM2BW is non-inclusive,
            %       while it is inclusive in INRANGE, hence the +1
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            gray = im2uint8(rgb2gray(img));
            level = graythresh(gray);  % level in [0,1] range
            BW1 = im2bw(gray, level);
            BW2 = cv.inRange(gray, fix(255*level)+1, 255);
            assert(isequal(BW1,BW2))
        end

        function test_error
            try
                cv.inRange();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
