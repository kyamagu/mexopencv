classdef TestRectify3Collinear
    %TestRectify3Collinear
    properties (Constant)
        fields = {'R1', 'R2', 'R3', 'P1', 'P2', 'P3', 'Q', ...
        'roi1', 'roi2', 'ratio'};
    end

    methods (Static)
        function test_1
            imgSz = [640 480];
            cam1 = eye(3);
            cam2 = eye(3);
            cam3 = eye(3);
            distort1 = zeros(1,5);
            distort2 = zeros(1,5);
            distort3 = zeros(1,5);
            R12 = [cv.getRotationMatrix2D(imgSz./2, 0, 1); 0 0 1];
            R13 = [cv.getRotationMatrix2D(imgSz./2, 0, 1); 0 0 1];
            T12 = [1; 0; 0];
            T13 = [1; 0; 0];
            S = cv.rectify3Collinear(cam1, distort1, cam2, distort2, ...
                cam3, distort3, imgSz, R12, T12, R13, T13, ...
                'ZeroDisparity',false, 'Alpha',-1, 'NewImageSize',imgSz./2);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestRectify3Collinear.fields, fieldnames(S))));
            validateattributes(S.R1, {'numeric'}, {'size',[3 3]});
            validateattributes(S.R2, {'numeric'}, {'size',[3 3]});
            validateattributes(S.R3, {'numeric'}, {'size',[3 3]});
            validateattributes(S.P1, {'numeric'}, {'size',[3 4]});
            validateattributes(S.P2, {'numeric'}, {'size',[3 4]});
            validateattributes(S.P3, {'numeric'}, {'size',[3 4]});
            validateattributes(S.Q, {'numeric'}, {'size',[4 4]});
            validateattributes(S.roi1, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
            validateattributes(S.roi2, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
            validateattributes(S.ratio, {'numeric'}, {'scalar'});
        end

        function test_error_1
            try
                cv.rectify3Collinear();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
