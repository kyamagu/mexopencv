classdef TestCopyMakeBorder
    %TestCopyMakeBorder
    properties (Constant)
    end

    methods (Static)
        function test_1
            src = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            border = {10, 20, 30, 40};
            dst = cv.copyMakeBorder(src, border{:}, 'BorderType','Default');
            dst = cv.copyMakeBorder(src, border{:}, 'BorderType','Reflect');
            dst = cv.copyMakeBorder(src, border{:}, 'BorderType','Reflect101');
            dst = cv.copyMakeBorder(src, border{:}, 'BorderType','Replicate');
            dst = cv.copyMakeBorder(src, border{:}, 'BorderType','Wrap');
            dst = cv.copyMakeBorder(src, border{:}, 'BorderType','Constant', ...
                'Value',[255 0 0]);
        end

        function test_error_1
            try
                cv.copyMakeBorder();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
