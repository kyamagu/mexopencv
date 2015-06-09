classdef TestConvertPointsFromHomogeneous
    %TestConvertPointsFromHomogeneous
    properties (Constant)
    end

    methods (Static)
        function test_numeric_3d
            pts = shiftdim([1,2,1; 4,5,1], -1);
            rct = cv.convertPointsFromHomogeneous(pts);
        end

        function test_numeric_4d
            pts = shiftdim([1,2,3,1; 4,5,6,1], -1);
            rct = cv.convertPointsFromHomogeneous(pts);
        end

        function test_cellarray_3d
            pts = {[1,2,1], [4,5,1]};
            rct = cv.convertPointsFromHomogeneous(pts);
        end

        function test_cellarray_4d
            pts = {[1,2,3,1], [4,5,6,1]};
            rct = cv.convertPointsFromHomogeneous(pts);
        end

        function test_all_formats_and_dims
            verify_numeric = @(M,n,d) assert( ...
                ismatrix(M) && isequal(size(M),[n d-1]));
            verify_cell = @(C,n,d) assert( ...
                iscell(C) && numel(C)==n && ...
                all(cellfun(@isvector, C)) && ...
                all(cellfun(@numel, C) == (d-1)));
            n = 10;
            % 3D/4D to 2D/3D
            for d=[3 4]
                % Nxd numeric matrix
                ptsH = rand([n,d]);
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_numeric(pts,n,d);

                % Nx1xd numeric matrix
                ptsH = rand([n,1,d]);
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_numeric(pts,n,d);

                % 1xNxd numeric matrix
                ptsH = rand([1,n,d]);
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_numeric(pts,n,d);

                % Nx1 cell array of 1xd points
                ptsH = num2cell(rand([n,d]), 2);
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_cell(pts,n,d);

                % 1xN cell array of 1xd points
                ptsH = num2cell(rand([n,d]), 2).';
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_cell(pts,n,d);

                % 1xN cell array of dx1 points
                ptsH = num2cell(rand([d,n]), 1);
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_cell(pts,n,d);

                % Nx1 cell array of dx1 points
                ptsH = num2cell(rand([d,n]), 1).';
                pts = cv.convertPointsFromHomogeneous(ptsH);
                verify_cell(pts,n,d);
            end
        end

        function test_last_dimension
            % xn = 0, xn = 1, and arbitrary xn
            for xn=[0 1 rand()]
                for d=[3 4]
                    ptsH = {[rand(1,d-1),xn], [rand(1,d-1),xn]};
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                end
            end
        end

        function test_error_1
            try
                cv.convertPointsFromHomogeneous();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

