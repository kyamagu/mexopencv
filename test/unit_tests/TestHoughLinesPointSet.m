classdef TestHoughLinesPointSet
    %TestHoughLinesPointSet

    methods (Static)
        function test_1
            % Rho = 320.00000, Theta = 1.04719
            pts = [
                0   369; 10  364; 20  358; 30  352; ...
                40  346; 50  341; 60  335; 70  329; ...
                80  323; 90  318; 100 312; 110 306; ...
                120 300; 130 295; 140 289; 150 284; ...
                160 277; 170 271; 180 266; 190 260
            ];

            lines = cv.HoughLinesPointSet(pts, ...
                'LinesMax',20, 'Threshold',1, ...
                'RhoMin',120, 'RhoMax',480, 'RhoStep',1, ...
                'ThetaMin',0, 'ThetaMax',pi/2, 'ThetaStep',pi/180);
            validateattributes(lines, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), lines);
        end

        function test_error_argnum
            try
                cv.HoughLinesPointSet();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
