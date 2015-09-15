classdef TestConvertPointsFromHomogeneous
    %TestConvertPointsFromHomogeneous

    methods (Static)
        function test_numeric_3d
            pts = shiftdim([1,2,1; 4,5,1], -1);
            dst = cv.convertPointsFromHomogeneous(pts);
            validateattributes(dst, {class(pts)}, {'size',[2 1 3-1]});
        end

        function test_numeric_4d
            pts = shiftdim([1,2,3,1; 4,5,6,1], -1);
            dst = cv.convertPointsFromHomogeneous(pts);
            validateattributes(dst, {class(pts)}, {'size',[2 1 4-1]});
        end

        function test_cellarray_3d
            pts = {[1,2,1], [4,5,1]};
            dst = cv.convertPointsFromHomogeneous(pts);
            validateattributes(dst, {'cell'}, {'vector', 'numel',numel(pts)});
            cellfun(@(p) validateattributes(p, {'numeric'}, ...
                {'vector', 'numel',3-1}), dst);
        end

        function test_cellarray_4d
            pts = {[1,2,3,1], [4,5,6,1]};
            dst = cv.convertPointsFromHomogeneous(pts);
            validateattributes(dst, {'cell'}, {'vector', 'numel',numel(pts)});
            cellfun(@(p) validateattributes(p, {'numeric'}, ...
                {'vector', 'numel',4-1}), dst);
        end

        function test_all_formats_and_dims
            verify_numeric = @(M,n,d) assert( ...
                ismatrix(M) && isequal(size(M),[n d-1]));
            verify_cell = @(C,n,d) assert( ...
                iscell(C) && numel(C)==n && ...
                all(cellfun(@isvector, C)) && ...
                all(cellfun(@numel, C) == (d-1)));
            % 3D/4D to 2D/3D
            n = 10;
            klass = {'double', 'single'};
            for k=1:numel(klass)
                for d=[3 4]
                    % Nxd numeric matrix
                    ptsH = rand([n,d], klass{k});
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {klass{k}}, {'2d', 'size',[n d-1]});

                    % Nx1xd numeric matrix
                    ptsH = rand([n,1,d], klass{k});
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {klass{k}}, {'3d', 'size',[n 1 d-1]});

                    % 1xNxd numeric matrix
                    ptsH = rand([1,n,d], klass{k});
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {klass{k}}, {'3d', 'size',[n 1 d-1]});

                    % Nx1 cell array of 1xd points
                    ptsH = num2cell(rand([n,d], klass{k}), 2);
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d-1}), pts);

                    % 1xN cell array of 1xd points
                    ptsH = num2cell(rand([n,d], klass{k}), 2).';
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d-1}), pts);

                    % 1xN cell array of dx1 points
                    ptsH = num2cell(rand([d,n], klass{k}), 1);
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d-1}), pts);

                    % Nx1 cell array of dx1 points
                    ptsH = num2cell(rand([d,n], klass{k}), 1).';
                    pts = cv.convertPointsFromHomogeneous(ptsH);
                    validateattributes(pts, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d-1}), pts);
                end
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
