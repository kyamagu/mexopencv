classdef TestFilterSpeckles
    %TestFilterSpeckles

    methods (Static)
        function test_1
            img1 = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            img2 = imread(fullfile(mexopencv.root(),'test','right01.jpg'));
            bm = cv.StereoBM();
            D = bm.compute(img1, img2);
            DD = cv.filterSpeckles(D, 0, 50, 16);
            validateattributes(DD, {'int16'}, {'size',size(D)});
        end

        function test_error_1
            try
                cv.filterSpeckles();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
