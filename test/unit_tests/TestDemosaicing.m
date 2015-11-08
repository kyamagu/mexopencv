classdef TestDemosaicing
    %TestDemosaicing

    methods (Static)
        function test_1
            src = randi([0 255], [200 200 1], 'uint8');
            dst = cv.demosaicing(src, 'BayerBG2GRAY');
            assert(isequal(size(dst,1), size(src,1)));
            assert(isequal(size(dst,2), size(src,2)));
            assert(isequal(class(dst), class(src)));
        end

        function test_2
            src = randi([0 255], [200 200 1], 'uint8');

            dst = cv.demosaicing(src, 'BayerBG2RGB');
            assert(isequal(size(dst,1), size(src,1)));
            assert(isequal(size(dst,2), size(src,2)));
            assert(isequal(class(dst), class(src)));

            dst = cv.demosaicing(src, 'BayerBG2RGB_VNG');
            assert(isequal(size(dst,1), size(src,1)));
            assert(isequal(size(dst,2), size(src,2)));
            assert(isequal(class(dst), class(src)));

            dst = cv.demosaicing(src, 'BayerBG2RGB_EA');
            assert(isequal(size(dst,1), size(src,1)));
            assert(isequal(size(dst,2), size(src,2)));
            assert(isequal(class(dst), class(src)));
        end

        function test_3
            src = randi([0 255], [200 200 1], 'uint8');
            dst = cv.demosaicing(src, 'BayerBG2GRAY', 'Channels',1);
            assert(size(dst,3) == 1);
        end

        function test_error_1
            try
                cv.demosaicing();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
