classdef TestDecolor
    %TestDecolor
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
    end

    methods (Static)
        function test_1
            [gray,clrBoosted] = cv.decolor(TestDecolor.img);
            sz = size(TestDecolor.img);
            validateattributes(gray, {'uint8'}, {'2d', 'size',sz(1:2)});
            validateattributes(clrBoosted, {'uint8'}, {'3d', 'size',sz});
        end

        function test_error_1
            try
                cv.decolor();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
