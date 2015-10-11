classdef TestRemap
    %TestRemap
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_1
            src = [1 0 0; 0 0 0; 0 0 0];
            X   = [0 0 0; 0 0 0; 0 0 0];
            Y   = [0 0 0; 0 0 0; 0 0 0];
            ref = [1 1 1; 1 1 1; 1 1 1];
            dst = cv.remap(src, X, Y);
            assert(isequal(ref, dst));
        end

        function test_2
            src = [1 0 0; 0 0 0; 0 0 0];
            X   = [0 0 0; 0 0 0; 0 0 0];
            Y   = [0 0 0; 0 0 0; 0 0 0];
            ref = [1 1 1; 1 1 1; 1 1 1];
            [m1,m2] = cv.convertMaps(X, Y);
            dst = cv.remap(src, m1, m2);
            assert(isequal(ref, dst));
        end

        function test_3_separate_maps
            % RGB image
            img = imread(TestRemap.im);

            [r,c,~] = size(img);
            [Y,X] = ndgrid((1:r)-1, (1:c)-1);  % 0-based indices

            % identity mapping
            dst = cv.remap(img, X, Y);
            assert(isequal(dst, img));

            % reflect image left to right
            dst = cv.remap(img, fliplr(X), Y);
            assert(isequal(dst, fliplr(img)));

            % turn image upside down
            dst = cv.remap(img, X, flipud(Y));
            assert(isequal(dst, flipud(img)));

            % combine previous two
            dst = cv.remap(img, fliplr(X), flipud(Y));
            assert(isequal(dst, rot90(img,2)));

            % rotate 90 degrees
            dst = cv.remap(img, rot90(X), rot90(Y));
            assert(isequal(dst, rot90(img)));

            % circularly shift in both directions (100 in cols, -200 in rows)
            dst = cv.remap(img, circshift(X, 100, 2), circshift(Y, -200, 1));
            assert(isequal(dst, circshift(circshift(img,100,2),-200,1)));

            % crop
            dst = cv.remap(img, X(1:200,1:300), Y(1:200,1:300));
            assert(isequal(dst, img(1:200,1:300,:)));

            % non-linear mapping
            dst = cv.remap(img, sqrt(X)*sqrt(c), Y.^2/r);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_4_combined_maps
            % grayscale image
            img = rgb2gray(imread(TestRemap.im));

            [r,c,~] = size(img);
            [Y,X] = ndgrid((1:r)-1, (1:c)-1);  % 0-based indices

            % reflect image left to right
            dst = cv.remap(img, cat(3, fliplr(X), Y));
            assert(isequal(dst, fliplr(img)));
        end

        function test_5_fixed_point
            % RGB image
            img = imread(TestRemap.im);

            [r,c,~] = size(img);
            [Y,X] = ndgrid((1:r)-1, (1:c)-1);  % 0-based indices

            % convert representation
            X = sqrt(X)*sqrt(c);
            Y = Y.^2/r;
            [XX,YY] = cv.convertMaps(X, Y);

            dst1 = cv.remap(img, X, Y);
            dst2 = cv.remap(img, XX, YY);
            assert(isequal(dst1, dst2));
            validateattributes(dst2, {class(img)}, {'size',size(img)});
        end

        function test_6_options
            % RGB image
            img = imread(TestRemap.im);

            [r,c,~] = size(img);
            [Y,X] = ndgrid((1:r)-1, (1:c)-1);  % 0-based indices

            dst = cv.remap(img, sqrt(X)*sqrt(c), Y.^2/r, ...
                'Interpolation','Linear', ...
                'BorderType','Constant', 'BorderValue',[0 0 0]);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_7_transparent
            img = imread(TestRemap.im);

            [r,c,~] = size(img);
            [Y,X] = ndgrid((1:r)-1, (1:c)-1);  % 0-based indices

            dst = cv.remap(img, [zeros(r,100)-1 X(:,101:end)], flipud(Y), ...
                'Dst',img, 'BorderType','Transparent');
            validateattributes(dst, {class(img)}, {'size',size(img)});
            isequal(dst, [img(:,1:100,:) flipud(img(:,101:end,:))]);
        end

        function test_error_1
            try
                cv.remap();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
