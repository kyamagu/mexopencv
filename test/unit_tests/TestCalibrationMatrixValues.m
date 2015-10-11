classdef TestCalibrationMatrixValues
    %TestCalibrationMatrixValues
    properties (Constant)
        fields = {'fovx', 'fovy', 'focalLength', 'principalPoint', 'aspectRatio'};
    end

    methods (Static)
        function test_1
            A = [1,0,.5; 0,1,.5; 0,0,1];
            S = cv.calibrationMatrixValues(A, [640,480], 4, 3);
            validateattributes(S, {'struct'}, {'scalar'});
            assert(all(ismember(TestCalibrationMatrixValues.fields, fieldnames(S))));
            cellfun(@(f) validateattributes(S.(f), {'double'}, {'scalar'}), ...
                TestCalibrationMatrixValues.fields([1:3 5]));
            validateattributes(S.principalPoint, {'numeric'}, ...
                {'vector', 'numel',2});
        end

        function test_error_1
            try
                cv.calibrationMatrixValues();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
