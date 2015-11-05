classdef TestHoughLines
    %TestHoughLines

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','left12.jpg'));
            lines = cv.HoughLines(img);
            validateattributes(lines, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2, 'real'}), lines);
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','left12.jpg'));
            lines = cv.HoughLines(img, ...
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
