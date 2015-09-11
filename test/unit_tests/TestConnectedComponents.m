classdef TestConnectedComponents
    %TestConnectedComponents
    properties (Constant)
        bw = logical(imread(fullfile(mexopencv.root(),'test','bw.png')));
    end

    methods (Static)
        function test_1
            [L,N,stats,centroids] = cv.connectedComponents(TestConnectedComponents.bw);
            assert(isinteger(L));
            validateattributes(L, {'numeric'}, ...
                {'size',size(TestConnectedComponents.bw), 'integer', 'nonnegative', '<',N}, ...
                'cv.connectedComponents', 'L');
            validateattributes(N, {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'cv.connectedComponents', 'N');
            validateattributes(stats, {'int32'}, {'size',[N 5]}, ...
                'cv.connectedComponents', 'stats');
            validateattributes(centroids, {'numeric'}, {'real', 'size',[N 2]}, ...
                'cv.connectedComponents', 'centroids');
        end

        function test_2
            [L,N] = cv.connectedComponents(TestConnectedComponents.bw, ...
                'Connectivity',8, 'LType','uint16');
            validateattributes(L, {'uint16'}, {}, '', 'L');
            assert(all(unique(L(:)) == (0:N-1)'));
        end

        function test_error_1
            try
                cv.connectedComponents();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
