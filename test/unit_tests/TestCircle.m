classdef TestCircle
    %TestCircle

    methods (Static)
        function test_circle
            img = 255*ones(64,64,3,'uint8');
            out = cv.circle(img, [32,32], 20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = zeros([50 50 3],'uint8');
            out = cv.circle(img, [25 25], 15, ...
                'Color',[255 0 0], 'Thickness','Filled', 'LineType',8);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.circle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
