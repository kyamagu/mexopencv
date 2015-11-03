classdef TestFindFundamentalMat
    %TestFindFundamentalMat

    methods (Static)
        function test_1
            for N=7:10  % at least 7 points
                p1 = rand(N,2);
                p2 = rand(N,2);
                p1(1,1) = 50;  % outlier
                estMethods = {'7Point', '8Point', 'Ransac', 'LMedS'};
                for i=1:numel(estMethods)
                    F = cv.findFundamentalMat(p1, p2, 'Method',estMethods{i});
                    [F, mask] = cv.findFundamentalMat(p1, p2, ...
                        'Method',estMethods{i}, 'Param1',3.0, 'Param2',0.99);
                    if ~isempty(F)
                        validateattributes(F, {'numeric'}, ...
                            {'real', 'size',[NaN 3]});
                        assert(size(F,1)==3 || size(F,1)==6 || size(F,1)==9);
                    end
                    validateattributes(mask, {'numeric','logical'}, ...
                        {'vector', 'numel',N, 'binary'});
                    %if i>2, assert(mask(1)==0); end
                end
            end
        end

        function test_2
            % we load data from CVST toolbox
            if ~license('test', 'video_and_image_blockset') || isempty(ver('vision'))
                disp('SKIP');
                return;
            end

            load stereoPointPairs
            F = cv.findFundamentalMat(matchedPoints1, matchedPoints2);
            validateattributes(F, {'numeric'}, {'real', 'size',[3 3]});
        end

        function test_error_1
            try
                cv.findFundamentalMat();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
