classdef TestAccumulateWeighted
    %TestAccumulateWeighted

    methods (Static)
        function test_1
            sz = [10 20];
            dst = zeros(sz);
            for i=1:5
                dst = cv.accumulateWeighted(rand(sz), dst, 0.5);
            end
            validateattributes(dst, {'double'}, {'size',sz});
        end

        function test_2
            sz = [10 20];
            dst = zeros(sz, 'single');
            for i=1:5
                dst = cv.accumulateWeighted(randi(255,sz,'uint8'), dst, 0.5);
            end
            validateattributes(dst, {'single'}, {'size',sz});
        end

        function test_3
            sz = [10 20];
            dst = zeros(sz);
            for i=1:5
                src = rand(sz);
                mask = (rand(sz) > 0.5);
                dst = cv.accumulateWeighted(src, dst, 0.5, 'Mask',mask);
            end
        end

        function test_error_1
            try
                cv.accumulateWeighted();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
