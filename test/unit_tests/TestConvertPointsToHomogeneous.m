classdef TestConvertPointsToHomogeneous
    %TestConvertPointsToHomogeneous

    methods (Static)
        function test_numeric_2d
            pts = shiftdim([1,2; 4,5], -1);
            dst = cv.convertPointsToHomogeneous(pts);
            validateattributes(dst, {class(pts)}, {'size',[2 1 2+1]});
        end

        function test_numeric_3d
            pts = shiftdim([1,2,3; 4,5,6], -1);
            dst = cv.convertPointsToHomogeneous(pts);
            validateattributes(dst, {class(pts)}, {'size',[2 1 3+1]});
        end

        function test_cellarray_2d
            pts = {[1,2], [4,5]};
            dst = cv.convertPointsToHomogeneous(pts);
            validateattributes(dst, {'cell'}, {'vector', 'numel',numel(pts)});
            cellfun(@(p) validateattributes(p, {'numeric'}, ...
                {'vector', 'numel',2+1}), dst);
        end

        function test_cellarray_3d
            pts = {[1,2,3], [4,5,6]};
            dst = cv.convertPointsToHomogeneous(pts);
            validateattributes(dst, {'cell'}, {'vector', 'numel',numel(pts)});
            cellfun(@(p) validateattributes(p, {'numeric'}, ...
                {'vector', 'numel',3+1}), dst);
        end

        function test_all_formats_and_dims
            % 2D/3D to 3D/4D
            n = 10;
            klass = {'double', 'single'};
            for k=1:numel(klass)
                for d=[2 3]
                    % Nxd numeric matrix
                    pts = rand([n,d], klass{k});
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {klass{k}}, {'2d', 'size',[n d+1]});

                    % Nx1xd numeric matrix
                    pts = rand([n,1,d], klass{k});
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {klass{k}}, {'3d', 'size',[n 1 d+1]});

                    % 1xNxd numeric matrix
                    pts = rand([1,n,d], klass{k});
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {klass{k}}, {'3d', 'size',[n 1 d+1]});

                    % Nx1 cell array of 1xd points
                    pts = num2cell(rand([n,d], klass{k}), 2);
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d+1}), ptsH);

                    % 1xN cell array of 1xd points
                    pts = num2cell(rand([n,d], klass{k}), 2).';
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d+1}), ptsH);

                    % 1xN cell array of dx1 points
                    pts = num2cell(rand([d,n], klass{k}), 1);
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d+1}), ptsH);

                    % Nx1 cell array of dx1 points
                    pts = num2cell(rand([d,n], klass{k}), 1).';
                    ptsH = cv.convertPointsToHomogeneous(pts);
                    validateattributes(ptsH, {'cell'}, {'vector', 'numel',n});
                    cellfun(@(p) validateattributes(p, {'numeric'}, ...
                        {'vector', 'numel',d+1}), ptsH);
                end
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
