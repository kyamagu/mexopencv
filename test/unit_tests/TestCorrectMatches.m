classdef TestCorrectMatches
    %TestCorrectMatches

    methods (Static)
        function test_formats
            N = 10;
            F = [0 0 0; 0 0 -1; 0 1 0];
            pts1 = rand(N,2);
            pts2 = rand(N,2);
            [newp1, newp2] = cv.correctMatches(F, pts1, pts2);
            % Nx2 -> Nx2, Nx1x2, 1xNx2, {[x,y],..}
            fcns = {@(pt) pt, @(pt) permute(pt,[1 3 2]), ...
                @(pt) permute(pt,[3 1 2]), @(pt) num2cell(pt,2)};
            % Nx2, 1xNx2, 1xNx2, {[x,y],..} -> Nx2
            fcnsInv = {@(pt) pt, @(pt) ipermute(pt,[3 1 2]), ...
                @(pt) ipermute(pt,[3 1 2]), @(pt) cat(1,pt{:})};
            for i=1:numel(fcns)
                [newPts1, newPts2] = cv.correctMatches(F, ...
                    feval(fcns{i}, pts1), feval(fcns{i}, pts2));
                assert(isequal(feval(fcnsInv{i}, newPts1), newp1));
                assert(isequal(feval(fcnsInv{i}, newPts2), newp2));
            end
        end

        function test_numeric
            N = 10;
            F = eye(3);
            pts1 = rand(N,2);
            pts2 = rand(N,2);
            [newPts1, newPts2] = cv.correctMatches(F, pts1, pts2);
            validateattributes(newPts1, {class(pts1)}, {'size',size(pts1)});
            validateattributes(newPts2, {class(pts2)}, {'size',size(pts2)});
        end

        function test_cellarray
            N = 10;
            F = eye(3);
            pts1 = num2cell(rand(N,2), 2);
            pts2 = num2cell(rand(N,2), 2);
            [newPts1, newPts2] = cv.correctMatches(F, pts1, pts2);
            validateattributes(newPts1, {'cell'}, ...
                {'vector', 'numel',numel(pts1)});
            validateattributes(newPts2, {'cell'}, ...
                {'vector', 'numel',numel(pts2)});
            cellfun(@(pt) validateattributes(pt, {'numeric'}, ...
                {'vector', 'numel',2}), newPts1);
            cellfun(@(pt) validateattributes(pt, {'numeric'}, ...
                {'vector', 'numel',2}), newPts2);
        end

        function test_error_1
            try
                cv.correctMatches();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
