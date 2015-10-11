classdef TestEllipse
    %TestEllipse

    methods (Static)
        function test_first_variant
            img = 255*ones(128,128,3,'uint8');
            out = cv.ellipse(img, [64,64], [20,10]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_second_variant
            img = 255*ones(128,128,3,'uint8');
            out = cv.ellipse(img, ...
                struct('center',[64,64], 'size',[20,10], 'angle',0));
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_compare_variants
            img = 255*ones([100 100 3],'uint8');
            pt = [50 50]; sz = [25 20]; deg = -50;
            img1 = cv.ellipse(img, pt, sz, 'Angle',deg);
            img2 = cv.ellipse(img, ...
                struct('center',pt, 'size',2*sz, 'angle',deg));
            assert(isequal(img1,img2));
            validateattributes(img1, {class(img)}, {'size',size(img)});
            validateattributes(img2, {class(img)}, {'size',size(img)});
        end

        function test_options
            % rotated ellipse
            img = 255*ones(128,128,3,'uint8');
            img = cv.ellipse(img, [64,64], [20,10], 'Angle',60);

            % arc
            img = 255*ones(128,128,3,'uint8');
            img = cv.ellipse(img, [64,64], [20,10], ...
                'StartAngle',20, 'EndAngle',300, ...
                'LineType','AA', 'Thickness',3);

            % filled
            img = zeros(128,128,3,'uint8');
            img = cv.ellipse(img, [64,64], [20,10], ...
                'Color',[255,0,255], 'Thickness','Filled');
            img = cv.ellipse(img, ...
                struct('center',[64,64], 'size',[40,20], 'Angle',0), ...
                'Color',[0,255,0], 'Thickness',-1);
        end

        function test_error_argnum
            try
                cv.ellipse();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_arg
            try
                cv.ellipse(zeros(100), [], []);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_nonexistant_option
            try
                cv.ellipse(zeros(100), [50,50], [10,20], 'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_option_value
            try
                cv.ellipse(zeros(100), [50,50], [10,20], 'LineType','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_second_variant_options
            try
                cv.ellipse(zeros(100), ...
                    struct('center',[50,50], 'size',[20,40], 'angle',0), ...
                    'StartAngle',45);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
