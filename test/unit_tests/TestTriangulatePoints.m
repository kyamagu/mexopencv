classdef TestTriangulatePoints
    %TestTriangulatePoints

    methods (Static)
        function test_formats
            N = 10;
            P1 = [250 0 200 0; 0 250 150 0; 0 0 1 0];
            P2 = [250 0 200 -250; 0 250 150 0; 0 0 1 0];
            pts1 = rand(2,N);
            pts2 = rand(2,N);
            p4D = cv.triangulatePoints(P1, P2, pts1, pts2);
            % 2xN -> 2xN, Nx1x2, 1xNx2, {[x,y],..}
            fcns = {@(pt) pt, @(pt) permute(pt,[2 3 1]), ...
                @(pt) permute(pt,[3 2 1]), @(pt) num2cell(pt,1)};
            for i=1:numel(fcns)
                points4D = cv.triangulatePoints(P1, P2, ...
                    feval(fcns{i}, pts1), feval(fcns{i}, pts2));
                assert(isequal(points4D, p4D));
            end
        end

        function test_numeric
            N = 10;
            P1 = eye(3,4);
            P2 = eye(3,4);
            pts1 = rand(2,N, 'single');
            pts2 = rand(2,N, 'single');
            points4D = cv.triangulatePoints(P1, P2, pts1, pts2);
            validateattributes(points4D, {class(pts1)}, {'size',[4 N]});
        end

        function test_cellarray
            N = 10;
            P1 = eye(3,4);
            P2 = eye(3,4);
            pts1 = num2cell(rand(N,2), 2);
            pts2 = num2cell(rand(N,2), 2);
            points4D = cv.triangulatePoints(P1, P2, pts1, pts2);
            validateattributes(points4D, {'numeric'}, {'size',[4 N]});
        end

        function test_error_1
            try
                cv.triangulatePoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
