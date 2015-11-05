classdef TestHoughCircles
    %TestHoughCircles

    methods (Static)
        function test_1
            im = cv.imread(fullfile(mexopencv.root(),'test','balloon.jpg'), 'Grayscale',true);
            circles = cv.HoughCircles(im, 'Method','Gradient', 'DP',2, ...
                'Param1',500, 'Param2',5, ...
                'MinDist',150, 'MinRadius',0, 'MaxRadius',80);
            validateattributes(circles, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3, 'real'}), circles);
        end

        function test_error_1
            try
                cv.HoughCircles();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
