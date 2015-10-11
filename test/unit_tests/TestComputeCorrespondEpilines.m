classdef TestComputeCorrespondEpilines
    %TestComputeCorrespondEpilines

    methods (Static)
        function test_numeric_Nx2
            N = 10;
            pts = rand(N,2);
            F = eye(3);
            lines = cv.computeCorrespondEpilines(pts, F);
            validateattributes(lines, {class(pts)}, {'size',[N 3]});
        end

        function test_numeric_Nx1x2
            N = 10;
            pts = permute(rand(N,2,'single'), [1 3 2]);
            F = eye(3);
            lines = cv.computeCorrespondEpilines(pts, F, 'WhichImage',1);
            validateattributes(lines, {class(pts)}, {'size',[N 1 3]});
        end

        function test_cellarray
            N = 10;
            pts = num2cell(rand(N,2),2);
            F = eye(3);
            lines = cv.computeCorrespondEpilines(pts, F, 'WhichImage',2);
            validateattributes(lines, {'cell'}, {'vector', 'numel',N});
            cellfun(@(l) validateattributes(l, {'numeric'}, ...
                {'vector', 'numel',3}), lines);
        end

        function test_error_1
            try
                cv.computeCorrespondEpilines();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
