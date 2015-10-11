classdef TestMatchShapes
    %TestMatchShapes

    methods (Static)
        function test_img_8bit
            img1 = randi(255, [50 50], 'uint8');
            img2 = randi(255, [50 50], 'uint8');
            score = cv.matchShapes(img1, img2);
            validateattributes(score, {'double'}, {'scalar'});
        end

        function test_img_float
            img1 = rand(10);
            img2 = rand(20);
            score = cv.matchShapes(img1, img2);
            validateattributes(score, {'double'}, {'scalar'});
        end

        function test_points
            contour1 = {[0,0], [1,0], [2,2], [3,3], [3,4]};
            contour2 = {[0,0], [1,0], [2,3], [3,3], [3,5]};
            score = cv.matchShapes(contour1, contour2);
            validateattributes(score, {'double'}, {'scalar'});
        end

        function test_error_1
            try
                cv.matchShapes();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
