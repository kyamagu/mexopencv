classdef TestEqualizeHist
    %TestEqualizeHist

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','left01.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);
            dst = cv.equalizeHist(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.equalizeHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
