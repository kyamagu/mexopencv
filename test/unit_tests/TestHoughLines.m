classdef TestHoughLines
    %TestHoughLines
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','left12.jpg'));
    end

    methods (Static)
        function test_1
            lines = cv.HoughLines(TestHoughLines.img);
            validateattributes(lines, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2, 'real'}), lines);
        end

        function test_2
            lines = cv.HoughLines(TestHoughLines.img, ...
                'Rho',1, 'Theta',pi/180, 'Threshold',80, ...
                'SRN',0, 'STN',0, 'MinTheta',0, 'MaxTheta',0);
        end

        function test_error_1
            try
                cv.HoughLines();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
