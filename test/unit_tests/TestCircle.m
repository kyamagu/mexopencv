classdef TestCircle
    %TestCircle

    methods (Static)
        function test_circle
            img = 255*ones(128,128,3,'uint8');
            out = cv.circle(img, [64,64], 20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = zeros([100 100 3],'uint8');
            out = cv.circle(img, [50 50], 30, ...
                'Color',[255 0 0], 'Thickness','Filled', 'LineType',8);
            validateattributes(out, {class(img)}, {'size',size(img)});
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
