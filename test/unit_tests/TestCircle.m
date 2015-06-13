classdef TestCircle
    %TestCircle
    properties (Constant)
    end

    methods (Static)
        function test_circle
            im = 255*ones(128,128,3,'uint8');
            im = cv.circle(im, [64,64], 20);
        end

        function test_options
            img = zeros([100 100 3],'uint8');
            img = cv.circle(img, [50 50], 30, ...
                'Color',[255 0 0], 'Thickness','Filled');
        end

        function test_error_1
            try
                cv.circle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
