classdef TestDecolor
    %TestDecolor

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            [gray,clrBoosted] = cv.decolor(img);
            sz = size(img);
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
