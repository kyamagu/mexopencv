classdef TestCLAHE
    %TestCLAHE
    properties (Constant)
        fname = fullfile(mexopencv.root,'test','img001.jpg');
    end

    methods (Static)
        function test_1
            src = cv.imread(TestCLAHE.fname, 'Flags',0);
            dst = cv.CLAHE(src, 'ClipLimit',40, 'TileGridSize',[8 8]);
            assert(isequal(size(dst), size(src)));
        end

        function test_error_1
            try
                cv.CLAHE();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
