classdef TestBuildPyramid
    %TestBuildPyramid

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            pyr = cv.buildPyramid(img, 'MaxLevel',3);
            validateattributes(pyr, {'cell'}, {'vector', 'numel',3+1});
            cellfun(@(v) validateattributes(v, ...
                {class(img)}, {'ndims',ndims(img)}), pyr);
            assert(isequal(pyr{1}, img));
        end

        function test_error_1
            try
                cv.buildPyramid();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
