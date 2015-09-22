classdef TestFind4QuadCornerSubpix
    %TestFind4QuadCornerSubpix
    properties (Constant)
        img = 255 * uint8([...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 1 1 1 1 0 0 0 0 0 ; ...
            0 0 0 0 1 1 1 1 0 0 0 0 0 ; ...
            0 0 0 0 1 1 1 1 0 0 0 0 0 ; ...
            0 0 0 0 1 1 1 1 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
            0 0 0 0 0 0 0 0 0 0 0 0 0 ; ...
        ]);
    end

    methods (Static)
        function test_cellarray
            corners = {[3,3], [8,8]};
            result = cv.find4QuadCornerSubpix(TestCornerSubPix.img, corners);
            validateattributes(result, {'cell'}, {'vector', ...
                'numel',numel(corners)});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2}), result);
        end

        function test_numeric_1
            corners = [3,3; 8,8];
            result = cv.find4QuadCornerSubpix(TestCornerSubPix.img, corners);
            validateattributes(result, {'numeric'}, {'size',size(corners)});
        end

        function test_numeric_2
            corners = cat(3, [3, 8], [3, 8]);
            result = cv.find4QuadCornerSubpix(TestCornerSubPix.img, corners);
            validateattributes(result, {'numeric'}, {'size',size(corners)});
        end

        function test_numeric_3
            corners = cat(3, [3; 8], [3; 8]);
            result = cv.find4QuadCornerSubpix(TestCornerSubPix.img, corners);
            validateattributes(result, {'numeric'}, {'size',size(corners)});
        end

        function test_error_1
            try
                cv.find4QuadCornerSubpix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
