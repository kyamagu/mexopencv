classdef TestConvertPointsToHomogeneous
    %TestConvertPointsToHomogeneous
    properties (Constant)
    end

    methods (Static)
        function test_numeric_2d
            pts = shiftdim([1,2; 4,5], -1);
            rct = cv.convertPointsToHomogeneous(pts);
        end

        function test_numeric_3d
            pts = shiftdim([1,2,3; 4,5,6], -1);
            rct = cv.convertPointsToHomogeneous(pts);
        end

        function test_cellarray_2d
            pts = {[1,2], [4,5]};
            rct = cv.convertPointsToHomogeneous(pts);
        end

        function test_cellarray_3d
            pts = {[1,2,3], [4,5,6]};
            rct = cv.convertPointsToHomogeneous(pts);
        end

        function test_all_formats_and_dims
            verify_numeric = @(M,n,d) assert( ...
                ismatrix(M) && isequal(size(M),[n d+1]));
            verify_cell = @(C,n,d) assert( ...
                iscell(C) && numel(C)==n && ...
                all(cellfun(@isvector, C)) && ...
                all(cellfun(@numel, C) == (d+1)));
            % 2D/3D to 3D/4D
            n = 10;
            for d=[2 3]
                % Nxd numeric matrix
                pts = rand([n,d]);
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_numeric(ptsH,n,d);

                % Nx1xd numeric matrix
                pts = rand([n,1,d]);
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_numeric(ptsH,n,d);

                % 1xNxd numeric matrix
                pts = rand([1,n,d]);
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_numeric(ptsH,n,d);

                % Nx1 cell array of 1xd points
                pts = num2cell(rand([n,d]), 2);
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_cell(ptsH,n,d);

                % 1xN cell array of 1xd points
                pts = num2cell(rand([n,d]), 2).';
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_cell(ptsH,n,d);

                % 1xN cell array of dx1 points
                pts = num2cell(rand([d,n]), 1);
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_cell(ptsH,n,d);

                % Nx1 cell array of dx1 points
                pts = num2cell(rand([d,n]), 1).';
                ptsH = cv.convertPointsToHomogeneous(pts);
                verify_cell(ptsH,n,d);
            end
        end

        function test_last_dimension
            for d=[2 3]
                pts = rand(10,d);
                ptsH = cv.convertPointsToHomogeneous(pts);
                assert(all(ptsH(:,end) == 1));
            end
        end

        function test_error_1
            try
                cv.convertPointsToHomogeneous();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

