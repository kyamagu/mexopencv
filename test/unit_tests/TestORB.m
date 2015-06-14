classdef TestORB
    %TestORB
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end

    methods (Static)
        function test_1
            obj = cv.ORB();
            [kpts,desc] = obj.detectAndCompute(TestORB.img);
        end

        function test_error_1
            try
                cv.ORB('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

