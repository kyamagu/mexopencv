classdef TestHoughLinesP
    %TestHoughLinesP
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','left12.jpg'));
    end

    methods (Static)
        function test_1
            lines = cv.HoughLinesP(TestHoughLinesP.img);
            validateattributes(lines, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'}), lines);
        end

        function test_2
            lines = cv.HoughLinesP(TestHoughLinesP.img, ...
                'Rho',1, 'Theta',pi/180, 'Threshold',80, ...
                'MinLineLength',0, 'MaxLineGap',0);
        end

        function test_error_1
            try
                cv.HoughLinesP();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
