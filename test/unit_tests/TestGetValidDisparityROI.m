classdef TestGetValidDisparityROI
    %TestGetValidDisparityROI

    methods (Static)
        function test_1
            roi1 = [0 0 640 480] + ...
                [randi([10 20], [1 2]), -randi([30 40], [1 2])];
            roi2 = [0 0 640 480] + ...
                [randi([10 20], [1 2]), -randi([30 40], [1 2])];
            r = cv.getValidDisparityROI(roi1, roi2, ...
                'MinDisparity',0, 'NumDisparities',64, 'BlockSize',11);
            validateattributes(r, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'});
        end

        function test_error_1
            try
                cv.getValidDisparityROI();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
