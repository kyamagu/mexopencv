classdef TestCalcBlurriness
    %TestCalcBlurriness

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            f = cv.calcBlurriness(img);
            validateattributes(f, {'numeric'}, {'scalar', 'real'});
        end

        function test_error_argnum
            try
                cv.calcBlurriness();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
