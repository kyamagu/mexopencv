classdef TestCLAHE
    %TestCLAHE

    methods (Static)
        function test_1
            src = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);
            dst = cv.CLAHE(src, 'ClipLimit',40, 'TileGridSize',[8 8]);
            assert(isequal(size(dst), size(src)));
        end

        function test_error_argnum
            try
                cv.CLAHE();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
