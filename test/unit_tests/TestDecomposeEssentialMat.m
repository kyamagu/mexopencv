classdef TestDecomposeEssentialMat
    %TestDecomposeEssentialMat
    properties (Constant)
        fields = {'R1', 'R2', 't'};
    end

    methods (Static)
        function test_1
            E = [0 0 0; 0 0 -1; 0 1 0];
            S = cv.decomposeEssentialMat(E);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestDecomposeEssentialMat.fields, fieldnames(S))));
            validateattributes(S.R1, {class(E)}, {'size',[3 3]});
            validateattributes(S.R2, {class(E)}, {'size',[3 3]});
            validateattributes(S.t, {class(E)}, {'vector', 'numel',3});
        end

        function test_error_1
            try
                cv.decomposeEssentialMat();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
