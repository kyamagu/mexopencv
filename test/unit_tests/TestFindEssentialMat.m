classdef TestFindEssentialMat
    %TestFindEssentialMat

    methods (Static)
        function test_1
            for N=5:10  % at least 5 points
                p1 = rand(N,2);
                p2 = rand(N,2);
                p1(1,1) = 50;  % outlier
                estMethods = {'Ransac', 'LMedS'};
                for i=1:numel(estMethods)
                    E = cv.findEssentialMat(p1, p2, 'Method',estMethods{i});
                    [E, mask] = cv.findEssentialMat(p1, p2, ...
                        'Method',estMethods{i}, 'CameraMatrix',eye(3), ...
                        'Threshold',1.0, 'Confidence',0.999);
                    if ~isempty(E)
                        validateattributes(E, {'numeric'}, ...
                            {'real', 'size',[NaN 3]});
                        assert(mod(size(E,1),3)==0 && size(E,1)<=30);
                    end
                    validateattributes(mask, {'numeric','logical'}, ...
                        {'vector', 'numel',N, 'binary'});
                    %if i>2, assert(mask(1)==0); end
                end
            end
        end

        function test_2
            % we load data from CVST toolbox
            if mexopencv.isOctave() || ~mexopencv.require('vision')
                error('mexopencv:testskip', 'toolbox');
            end

            load stereoPointPairs
            E = cv.findEssentialMat(matchedPoints1, matchedPoints2);
            validateattributes(E, {'numeric'}, {'real', 'size',[3 3]});
        end

        function test_error_argnum
            try
                cv.findEssentialMat();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
