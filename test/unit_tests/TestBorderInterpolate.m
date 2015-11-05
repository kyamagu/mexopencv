classdef TestBorderInterpolate
    %TestBorderInterpolate

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            [rows,cols,~] = size(img);
            r = cv.borderInterpolate(rows+50, rows, 'BorderType','Reflect101');
            c = cv.borderInterpolate(-5, cols, 'BorderType','Wrap');
            val = img(r+1, c+1, :);
        end

        function test_error_1
            try
                cv.borderInterpolate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
