classdef TestCopyMakeBorder
    %TestCopyMakeBorder

    methods (Static)
        function test_1
            src = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            [h,w,~] = size(src);
            border = [10, 20, 30, 40];
            types = {'Default', 'Reflect', 'Reflect101', 'Replicate', 'Wrap'};
            for i=1:numel(types)
                dst = cv.copyMakeBorder(src, border, 'BorderType',types{i});

                [hh,ww,~] = size(dst);
                assert(hh == (h+border(1)+border(2)));
                assert(ww == (w+border(3)+border(4)));
                assert(ndims(src) == ndims(dst));

                src2 = dst((1:h)+border(1), (1:w)+border(3), :);
                assert(isequal(src2, src));
            end
        end

        function test_2
            src = magic(5);
            dst = cv.copyMakeBorder(src, [1 2 3 4], ...
                'BorderType','Constant', 'Value',0);
        end

        function test_3
            src = magic(5);
            dst = cv.copyMakeBorder(src, 1, 2, 3, 4);
            dst = cv.copyMakeBorder(src, [1 2 3 4]);
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
