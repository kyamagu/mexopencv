classdef TestDecomposeProjectionMatrix
    %TestDecomposeProjectionMatrix
    properties (Constant)
        fields = {'rotMatrX', 'rotMatrY', 'rotMatrZ', 'eulerAngles'};
    end

    methods (Static)
        function test_outputs
            klass = {'double', 'single'};
            for k=1:numel(klass)
                P = eye(3,4, klass{k});
                [K,R,T] = cv.decomposeProjectionMatrix(P);
                [K,R,T,S] = cv.decomposeProjectionMatrix(P);
                validateattributes(K, {class(P)}, {'size',[3 3]});
                validateattributes(R, {class(P)}, {'size',[3 3]});
                validateattributes(T, {class(P)}, {'vector', 'numel',4});
                validateattributes(S, {'struct'}, {'scalar'});
                assert(all(ismember(TestDecomposeProjectionMatrix.fields, ...
                    fieldnames(S))));
                cellfun(@(f) validateattributes(S.(f), {class(P)}, ...
                    {'2d', 'size',[3 3]}), ...
                    TestDecomposeProjectionMatrix.fields(1:3));
                validateattributes(S.eulerAngles, {'double'}, ...
                    {'vector', 'numel',3});
            end
        end

        function test_accuracy
            % create original camera matrix, rotation, and translation
            f = randi([300 1000], [2 1]);
            c = randi([150 600], [2 1]);
            alpha = 0.01*randn();
            origK = [f(1) alpha*f(1) c(1);
                       0        f(2) c(2);
                       0          0    1];
            origR = cv.Rodrigues((rand(3,1)*2 - 1) * pi);
            origT = randn(3,1);

            % compose the projection matrix
            P = origK * [origR, origT];

            % decompose
            [K,R,homogCameraCenter] = cv.decomposeProjectionMatrix(P);

            % recover translation from the camera center
            T = -R * (homogCameraCenter(1:3)./homogCameraCenter(4));

            % compare
            assert(norm(K - origK) < 1e-3, 'bad accuracy');
            assert(norm(R - origR) < 1e-3, 'bad accuracy');
            assert(norm(T - origT) < 1e-3, 'bad accuracy');
        end

        function test_error_1
            try
                cv.decomposeProjectionMatrix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
