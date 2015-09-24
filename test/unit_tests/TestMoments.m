classdef TestMoments
    %TestMoments
    properties (Constant)
        fields = {'m00','m10','m01','m20','m11','m02','m30','m21','m12','m03', ...
            'mu20','mu11','mu02','mu30','mu21','mu12','mu03', ...
            'nu20','nu11','nu02','nu30','nu21','nu12','nu03'};
    end

    methods (Static)
        function test_img_8bit
            img = randi(255, [50 50], 'uint8');
            mo = cv.moments(img);
            validateattributes(mo, {'struct'}, {'scalar'});
            assert(all(ismember(TestMoments.fields, fieldnames(mo))));
        end

        function test_img_float
            img = rand(50);
            mo = cv.moments(img);
            validateattributes(mo, {'struct'}, {'scalar'});
            assert(all(ismember(TestMoments.fields, fieldnames(mo))));
        end

        function test_img_binary
            bw = logical(rand(10) > 0.5);
            m1 = cv.moments(bw);
            m2 = cv.moments(uint8(bw*255), 'BinaryImage',true);
            validateattributes(m1, {'struct'}, {'scalar'});
            validateattributes(m2, {'struct'}, {'scalar'});
            assert(isequal(m1,m2));
        end

        function test_points_int
            pt = num2cell(randi(500,[10,2],'int32'), 2);
            mo = cv.moments(pt);
            validateattributes(mo, {'struct'}, {'scalar'});
            assert(all(ismember(TestMoments.fields, fieldnames(mo))));
        end

        function test_points_float
            pt = num2cell(rand(10,2), 2);
            mo = cv.moments(pt);
            validateattributes(mo, {'struct'}, {'scalar'});
            assert(all(ismember(TestMoments.fields, fieldnames(mo))));
        end

        function test_error_1
            try
                cv.moments();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
