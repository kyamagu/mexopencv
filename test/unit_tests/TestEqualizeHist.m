classdef TestEqualizeHist
    %TestEqualizeHist
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
    end

    methods (Static)
        function test_1
            dst = cv.equalizeHist(TestEqualizeHist.img);
            validateattributes(dst, {class(TestEqualizeHist.img)}, ...
                {'size',size(TestEqualizeHist.img)});
        end

        function test_error_1
            try
                cv.equalizeHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
