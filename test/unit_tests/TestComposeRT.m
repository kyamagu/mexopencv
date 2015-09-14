classdef TestComposeRT
    %TestComposeRT
    properties (Constant)
        fields = {'rvec3', 'tvec3', 'dr3dr1', 'dr3dt1', ...
            'dr3dr2', 'dr3dt2', 'dt3dr1', 'dt3dt1', 'dt3dr2', 'dt3dt2'};
    end

    methods (Static)
        function test_1
            rvec1 = zeros(3,1);
            tvec1 = zeros(3,1);
            rvec2 = zeros(3,1);
            tvec2 = zeros(3,1);
            S = cv.composeRT(rvec1, tvec1, rvec2, tvec2);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestComposeRT.fields, fieldnames(S))));
            cellfun(@(f) validateattributes(S.(f), {'double'}, ...
                {'vector', 'numel',3}), TestComposeRT.fields(1:2));
            cellfun(@(f) validateattributes(S.(f), {'double'}, ...
                {'2d', 'size',[3 3]}), TestComposeRT.fields(3:end));
        end

        function test_2
            rvec1 = rand(3,1, 'single');
            tvec1 = rand(3,1, 'single');
            rvec2 = rand(3,1, 'single');
            tvec2 = rand(3,1, 'single');
            S = cv.composeRT(rvec1, tvec1, rvec2, tvec2);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestComposeRT.fields, fieldnames(S))));
            cellfun(@(f) validateattributes(S.(f), {'single'}, ...
                {'vector', 'numel',3}), TestComposeRT.fields(1:2));
            cellfun(@(f) validateattributes(S.(f), {'single'}, ...
                {'2d', 'size',[3 3]}), TestComposeRT.fields(3:end));
        end

        function test_error_1
            try
                cv.composeRT();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
