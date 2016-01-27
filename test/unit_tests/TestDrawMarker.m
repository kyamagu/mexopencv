classdef TestDrawMarker
    %TestDrawMarker

    methods (Static)
        function test_1
            img = 255*ones(128,128,3,'uint8');
            out = cv.drawMarker(img, [64,64]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = zeros([100 400 3],'uint8');
            markers = '+x*ds^v';
            for i=1:numel(markers)
                img = cv.drawMarker(img, [50*i 50], ...
                    'Color',[255 0 0], 'MarkerType',markers(i), ...
                    'MarkerSize',30, 'Thickness',2, 'LineType','AA');
            end
            validateattributes(img, {'uint8'}, {'size',[100 400 3]});
        end

        function test_error_1
            try
                cv.drawMarker();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
