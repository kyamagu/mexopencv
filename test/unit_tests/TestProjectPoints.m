classdef TestProjectPoints
    %TestProjectPoints

    methods (Static)
        function test_1
            N = 10;
            funcs = {@(pts) pts, @(pts) permute(pts,[1 3 2]), @(pts) num2cell(pts,2)};
            szs = {[N 2], [N 1 2], N};
            pts = rand(N,3);
            rvec = [0 0 pi/4];
            tvec = [0 0 0];
            camMtx = [diag(rand(2,1)*100) rand(2,1)*50; 0 0 1];
            distCoeffs = ones(1,4)*1e-4;
            for i=1:numel(funcs)
                opts = feval(funcs{i}, pts);
                ipts = cv.projectPoints(opts, rvec, tvec, camMtx, ...
                    'DistCoeffs',distCoeffs);
                [ipts,J] = cv.projectPoints(opts, rvec, tvec, camMtx, ...
                    'DistCoeffs',distCoeffs);
                if isnumeric(opts)
                    validateattributes(ipts, {'numeric'}, {'size',szs{i}});
                else
                    validateattributes(ipts, {'cell'}, ...
                        {'vector', 'numel',szs{i}});
                    cellfun(@(pt) validateattributes(pt, {'numeric'}, ...
                        {'vector', 'numel',2}), ipts);
                end
                validateattributes(J, {'numeric'}, ...
                    {'size',[2*N 10+numel(distCoeffs)]});
            end
        end

        function test_error_1
            try
                cv.projectPoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
