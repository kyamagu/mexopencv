classdef TestCompareHist
    %TestCompareHist

    methods (Static)
        function test_1
            H1 = single(0:5);
            H2 = single(5:-1:0);
            d = cv.compareHist(H1, H2);
            validateattributes(d, {'double'}, {'scalar'});
        end

        function test_2
            H1 = randi(1000, [14 12 10], 'single');
            H2 = randi(1000, [14 12 10], 'single');
            d = cv.compareHist(H1, H2);
            validateattributes(d, {'double'}, {'scalar'});
        end

        function test_3
            H1 = round(sprand(100,100,0.01)*1000);
            H2 = round(sprand(100,100,0.01)*1000);
            d = cv.compareHist(H1,H2);
            validateattributes(d, {'double'}, {'scalar'});
        end

        function test_4
            H1 = randi(1000, [20 20], 'single');
            H2 = randi(1000, [20 20], 'single');
            comps = {'Correlation', 'ChiSquare', 'Intersection', ...
                'Bhattacharyya', 'Hellinger', 'AltChiSquare', ...
                'KullbackLeibler'};
            for i=1:numel(comps)
                d = cv.compareHist(H1, H2, 'Method',comps{i});
                validateattributes(d, {'double'}, {'scalar'});
            end
        end

        function test_error_argnum
            try
                cv.compareHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
