classdef TestDemosaicing
    %TestDemosaicing
    properties (Constant)
        src = randi([0 255], [200 200 1], 'uint8');
    end

    methods (Static)
        function test_1
            dst = cv.demosaicing(TestDemosaicing.src, 'BayerBG2GRAY');
            assert(isequal(size(dst,1), size(TestDemosaicing.src,1)));
            assert(isequal(size(dst,2), size(TestDemosaicing.src,2)));
            assert(isequal(class(dst), class(TestDemosaicing.src)));
        end

        function test_2
            dst = cv.demosaicing(TestDemosaicing.src, 'BayerBG2RGB');
            assert(isequal(size(dst,1), size(TestDemosaicing.src,1)));
            assert(isequal(size(dst,2), size(TestDemosaicing.src,2)));
            assert(isequal(class(dst), class(TestDemosaicing.src)));

            dst = cv.demosaicing(TestDemosaicing.src, 'BayerBG2RGB_VNG');
            assert(isequal(size(dst,1), size(TestDemosaicing.src,1)));
            assert(isequal(size(dst,2), size(TestDemosaicing.src,2)));
            assert(isequal(class(dst), class(TestDemosaicing.src)));

            dst = cv.demosaicing(TestDemosaicing.src, 'BayerBG2RGB_EA');
            assert(isequal(size(dst,1), size(TestDemosaicing.src,1)));
            assert(isequal(size(dst,2), size(TestDemosaicing.src,2)));
            assert(isequal(class(dst), class(TestDemosaicing.src)));
        end

        function test_3
            dst = cv.demosaicing(TestDemosaicing.src, 'BayerBG2GRAY', 'Channels',1);
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
