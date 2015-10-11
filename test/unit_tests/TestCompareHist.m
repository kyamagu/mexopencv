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
            H1 = randi(1000, [50 40 30], 'single');
            H2 = randi(1000, [50 40 30], 'single');
            d = cv.compareHist(H1, H2);
            validateattributes(d, {'double'}, {'scalar'});
        end

        function test_3
            H1 = round(sprand(500,500,0.01)*1000);
            H2 = round(sprand(500,500,0.01)*1000);
            d = cv.compareHist(H1,H2);
            validateattributes(d, {'double'}, {'scalar'});
        end

        function test_4
            H1 = randi(1000, [50 50], 'single');
            H2 = randi(1000, [50 50], 'single');
            comps = {'Correlation', 'ChiSquare', 'Intersection', ...
                'Bhattacharyya', 'Hellinger', 'AltChiSquare', ...
                'KullbackLeibler'};
            for i=1:numel(comps)
                d = cv.compareHist(H1, H2, 'Method',comps{i});
                validateattributes(d, {'double'}, {'scalar'});
            end
        end

        function test_error_1
            try
                cv.compareHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
