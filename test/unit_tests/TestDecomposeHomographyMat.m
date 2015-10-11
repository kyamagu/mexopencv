classdef TestDecomposeHomographyMat
    %TestDecomposeHomographyMat
    properties (Constant)
        fields = {'R', 't', 'n'};
    end

    methods (Static)
        function test_1
            H = eye(3);
            K = eye(3);
            [S,nsols] = cv.decomposeHomographyMat(H, K);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestDecomposeHomographyMat.fields, fieldnames(S))));
            validateattributes(nsols, {'numeric'}, {'scalar', 'integer'});
            validateattributes(S.R, {'cell'}, {'numel',nsols});
            cellfun(@(R) validateattributes(R, {'numeric'}, {'size',[3 3]}), S.R);
            validateattributes(S.t, {'cell'}, {'numel',nsols});
            cellfun(@(t) validateattributes(t, {'numeric'}, {'vector', 'numel',3}), S.t);
            validateattributes(S.n, {'cell'}, {'numel',nsols});
            cellfun(@(n) validateattributes(n, {'numeric'}, {'vector', 'numel',3}), S.n);
        end

        function test_error_1
            try
                cv.decomposeHomographyMat();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
