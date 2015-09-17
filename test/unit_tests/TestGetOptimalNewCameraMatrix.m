classdef TestGetOptimalNewCameraMatrix
    %TestGetOptimalNewCameraMatrix

    methods (Static)
        function test_1
            camMtx = [diag(rand(2,1)*100) rand(2,1)*50; 0 0 1];
            distCoeffs = ones(1,4)*1e-4;
            imgSz = [100 100];
            for alpha=0:0.25:1
                A = cv.getOptimalNewCameraMatrix(camMtx, distCoeffs, imgSz, ...
                    'Alpha',alpha);
                validateattributes(A, {class(camMtx)}, ...
                    {'2d', 'real', 'size',[3 3]});
            end
        end

        function test_2
            camMtx = single([diag(rand(2,1)*100) rand(2,1)*50; 0 0 1]);
            [A,validPixROI] = cv.getOptimalNewCameraMatrix(camMtx, ...
                zeros(1,4), [100 100], 'Alpha',0.5, ...
                'NewImageSize',[80 80], 'CenterPrincipalPoint',true);
            validateattributes(A, {class(camMtx)}, ...
                {'2d', 'real', 'size',[3 3]});
            validateattributes(validPixROI, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
        end

        function test_error_1
            try
                cv.getOptimalNewCameraMatrix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
