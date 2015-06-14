classdef TestFlip

    methods (Static)
        function test_1
            src = magic(5);

            dst = cv.flip(src, 0);
            assert(isequal(size(dst), size(dst)));

            dst = cv.flip(src, 1);
            assert(isequal(size(dst), size(dst)));

            dst = cv.flip(src, -1);
            assert(isequal(size(dst), size(dst)));
        end

        function test_2
            src = magic(5);

            dst = cv.flip(cv.flip(src, 0), 0);
            assert(isequal(src, dst));

            dst = cv.flip(cv.flip(src, 1), 1);
            assert(isequal(src, dst));

            dst = cv.flip(cv.flip(src, -1), -1);
            assert(isequal(src, dst));
        end

        function test_3
            src = magic(5);

            dst1 = cv.flip(cv.flip(src, 0), 1);
            dst2 = cv.flip(src, -1);
            assert(isequal(dst1, dst2));
        end

        function test_error_1
            try
                cv.flip();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
