classdef TestGetRectSubPix
    %TestGetRectSubPix

    methods (Static)
        function test_1
            src = single([0 0 0; 0 1 1; 0 1 1]);
            ref = single([0 0; 0 0.5625]);
            dst = cv.getRectSubPix(src, [2,2], [0.25,0.25]);
            validateattributes(dst, {'single'}, {'2d', 'size',[2 2]});
            assert(isequal(dst,ref));
        end

        function test_2
            src = randi(255, [100 100], 'uint8');
            sz = [10 20];
            center = [50 50];
            dst = cv.getRectSubPix(src, sz, center, 'PatchType','single');
            validateattributes(dst, {'single'}, {'2d', 'size',[sz(2) sz(1)]});
        end

        function test_3
            src = randi(255, [100,100,3], 'uint8');
            sz = [10 20];
            center = [50 50];
            dst = cv.getRectSubPix(src, sz, center);
            validateattributes(dst, {'uint8'}, {'3d', 'size',[sz(2) sz(1) 3]});
        end

        function test_error_1
            try
                cv.getRectSubPix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
