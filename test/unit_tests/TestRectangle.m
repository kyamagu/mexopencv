classdef TestRectangle
    %TestRectangle
    properties (Constant)
    end

    methods (Static)
        function test_first_variant
            im = 255*ones(128,128,3,'uint8');
            im = cv.rectangle(im, [64,64], [20,10]);
        end

        function test_second_variant
            img = 255*ones(128,128,3,'uint8');
            img = cv.rectangle(img, [64,64,20,10]);
        end

        function test_compare_variants
            img = 255*ones([100,100,3],'uint8');
            x = 20; y = 30; w = 50; h = 40;
            img1 = cv.rectangle(img, [x,y,w,h]);
            img2 = cv.rectangle(img, [x,y], [x+w-1,y+h-1]);
            assert(isequal(img1,img2));
        end

        function test_options
            img = zeros(100,100,3,'uint8');
            img = cv.rectangle(img, [20,20], [80,80], ...
                'Color',[255 0 0], 'Thickness','Filled', 'LineType',8);
        end

        function test_error_1
            try
                cv.rectangle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
