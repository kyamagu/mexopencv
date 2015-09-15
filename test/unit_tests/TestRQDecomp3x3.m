classdef TestRQDecomp3x3
    %TestRQDecomp3x3
    properties (Constant)
        fields = {'Qx', 'Qy', 'Qz', 'eulerAngles'};
    end

    methods (Static)
        function test_1
            M = [cos(pi/4) sin(pi/4) 0 ; ...
                -sin(pi/4) cos(pi/4) 0 ; ...
                         0         0 1];
            [Q,R] = qr(M);
            [R,Q] = cv.RQDecomp3x3(M);
            [R,Q,S] = cv.RQDecomp3x3(M);
            validateattributes(R, {class(M)}, {'size',[3 3]});
            assert(istriu(R), 'Not upper triangular');
            assert(abs(norm(Q)-1) < 1e-9 && norm(Q'-inv(Q)) < 1e-9, 'Not orthogonal');
            validateattributes(Q, {class(M)}, {'size',[3 3]});
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestRQDecomp3x3.fields, fieldnames(S))));
            cellfun(@(f) validateattributes(S.(f), {class(M)}, ...
                {'2d', 'size',[3 3]}), TestRQDecomp3x3.fields(1:3));
            validateattributes(S.eulerAngles, {'double'}, ...
                {'vector', 'numel',3});
        end

        function test_error_1
            try
                cv.RQDecomp3x3();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
