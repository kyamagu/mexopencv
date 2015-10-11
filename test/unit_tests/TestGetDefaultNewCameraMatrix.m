classdef TestGetDefaultNewCameraMatrix
    %TestGetDefaultNewCameraMatrix

    methods (Static)
        function test_1
            newcammat = cv.getDefaultNewCameraMatrix(eye(3));
            validateattributes(newcammat, {'double'}, {'size',[3 3]});
        end

        function test_2
            newcammat = cv.getDefaultNewCameraMatrix(eye(3), ...
                'ImgSize',[15 20], 'CenterPrincipalPoint',true);
            validateattributes(newcammat, {'double'}, {'size',[3 3]});
        end

        function test_error_1
            try
                cv.getDefaultNewCameraMatrix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
