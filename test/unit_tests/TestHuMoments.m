classdef TestHuMoments
    %TestMoments

    methods (Static)
        function test_1
            mo = struct('m00',1,'m10',1,'m01',1,'m20',1,'m11',1,'m02',1,...
                'm30',1,'m21',1,'m12',1,'m03',1);
            hu = cv.HuMoments(mo);
            validateattributes(hu, {'double'}, {'vector', 'numel',7});
        end

        function test_2
            img = randi(255, [10 10], 'uint8');
            mo = cv.moments(img);
            hu = cv.HuMoments(mo);
            validateattributes(hu, {'double'}, {'vector', 'numel',7});
        end

        function test_error_1
            try
                cv.HuMoments();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
