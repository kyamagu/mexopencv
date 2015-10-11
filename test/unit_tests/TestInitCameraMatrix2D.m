classdef TestInitCameraMatrix2D
    %TestInitCameraMatrix2D

    methods (Static)
        function test_1
            % {[x,y; x,y; ..], ...}
            opts = {rand(10,3)*100, rand(8,3)*100};
            ipts = {rand(10,2)*100, rand(8,2)*100};
            A = cv.initCameraMatrix2D(opts, ipts, [100 100]);
            validateattributes(A, {'numeric'}, {'2d', 'real', 'size',[3 3]});
        end

        function test_2
            % {{[x,y], ..}, ...}
            opts = {num2cell(rand(10,3)*100,2), num2cell(rand(8,3)*100,2)};
            ipts = {num2cell(rand(10,2)*100,2), num2cell(rand(8,2)*100,2)};
            A = cv.initCameraMatrix2D(opts, ipts, [100 100]);
            validateattributes(A, {'numeric'}, {'2d', 'real', 'size',[3 3]});
        end

        function test_error_1
            try
                cv.initCameraMatrix2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
