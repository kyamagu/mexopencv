classdef TestEMD
    %TestEMD

    methods (Static)
        function test_1
            H1 = single([1 0; 1 0;1 1; 1 2;]);
            H2 = single([1 0;.5 0;1 1;.8 2;]);
            d = cv.EMD(H1, H2);
        end

        function test_2
            % we use NORMPDF from Statistics Toolbox
            if mexopencv.isOctave()
                stat_lic = 'statistics';
                stat_pkg = stat_lic;
            else
                stat_lic = 'statistics_toolbox';
                stat_pkg = 'stats';
            end
            if ~license('test', stat_lic) || isempty(ver(stat_pkg))
                disp('SKIP');
                return;
            end

            % signatures of two 1D histograms
            x = linspace(-4,4,50).'; sig1 = [normpdf(x, 0, 1) x];
            x = linspace(-5,5,50).'; sig2 = [normpdf(x, 1, 3) x];

            dists = {'L2', 'L1', 'C'};
            for i=1:numel(dists)
                d = cv.EMD(sig1, sig2, 'DistType',dists{i});
                [d,lb,flow] = cv.EMD(sig1, sig2, 'DistType',dists{i});
                validateattributes(d, {'numeric'}, {'scalar', 'real'});
                validateattributes(lb, {'numeric'}, {'scalar', 'real'});
                validateattributes(flow, {'single'}, ...
                    {'size',[size(sig1,1) size(sig2,1)]});
            end
        end

        function test_3
            N1 = 5; N2 = 5;
            cost = rand(N1,N2); cost = cost * cost.';
            w1 = rand(N1,1); w2 = rand(N2,1);

            d = cv.EMD(w1, w2, 'Cost',cost, 'DistType','User');
            validateattributes(d, {'numeric'}, {'scalar', 'real'});
        end

        function test_error_1
            try
                cv.EMD();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
