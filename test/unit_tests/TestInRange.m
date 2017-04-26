classdef TestInRange
    %TestInRange

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            bw = cv.inRange(img, 50, 200);
            validateattributes(bw, {'logical'}, {'2d', 'size',size(img)});
        end

        function test_rgb_image
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            hsv = cv.cvtColor(img, 'RGB2HSV');
            bw = cv.inRange(hsv, [10 0 0], [165,255,255]);  % red hue
            validateattributes(bw, {'logical'}, ...
                {'2d', 'size',[size(img,1) size(img,2)]});
        end

        function test_grayscale_image
            % we use GRAYTHRESH/IM2BW from Image Processing Toolbox
            if ~mexopencv.require('images')
                error('mexopencv:testskip', 'toolbox');
            end

            % compare against IM2BW
            % Note: lower bound in IM2BW is non-inclusive,
            %       while it is inclusive in INRANGE, hence the +1
            gray = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'Grayscale',true);
            assert(isa(gray,'uint8'));
            level = graythresh(gray);  % level in [0,1] range
            BW1 = im2bw(gray, level);
            BW2 = cv.inRange(gray, fix(255*level)+1, 255);
            assert(isequal(BW1,BW2))
        end

        function test_error_argnum
            try
                cv.inRange();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
