classdef TestPyrMeanShiftFiltering
    %TestPyrMeanShiftFiltering

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            result = cv.pyrMeanShiftFiltering(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            result = cv.pyrMeanShiftFiltering(img, ...
                'SP',5, 'SR',10, 'MaxLevel',1);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.pyrMeanShiftFiltering();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
