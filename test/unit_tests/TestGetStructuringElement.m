classdef TestGetStructuringElement
    %TestGetStructuringElement

    methods (Static)
        function test_1
            elem = cv.getStructuringElement();
        end

        function test_2
            shapes = {'Rect', 'Cross', 'Ellipse'};
            for i=1:numel(shapes)
                elem = cv.getStructuringElement(...
                    'Shape',shapes{i}, 'KSize',[3 3]);
                validateattributes(elem, {'numeric'}, {'size',[3 3]});
            end
        end

        function test_error_1
            try
                cv.getStructuringElement(1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
