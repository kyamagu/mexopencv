classdef TestConnectedComponents
    %TestConnectedComponents
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','bw.png');
    end

    methods (Static)
        function test_1
            bw = logical(imread(TestConnectedComponents.im));
            [L,N,stats,centroids] = cv.connectedComponents(bw);
            assert(isinteger(L));
            validateattributes(L, {'numeric'}, ...
                {'size',size(bw), 'integer', 'nonnegative', '<',N});
            validateattributes(N, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative'});
            validateattributes(stats, {'int32'}, {'size',[N 5]});
            validateattributes(centroids, {'numeric'}, {'real', 'size',[N 2]});
        end

        function test_2
            bw = logical(imread(TestConnectedComponents.im));
            [L,N] = cv.connectedComponents(bw, ...
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
