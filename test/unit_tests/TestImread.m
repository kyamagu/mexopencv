classdef TestImread
    %TestImread
    properties (Constant)
        filename = fullfile(mexopencv.root(),'test','RubberWhale1.png');
    end

    methods (Static)
        function test_read_color
            im1 = cv.imread(TestImread.filename);  % 'Color',true
            validateattributes(im1, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});

            im2 = cv.imread(TestImread.filename, 'Flags',1);
            validateattributes(im2, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});

            assert(isequal(im1,im2), 'Images are not equal');
        end

        function test_read_grayscale
            im1 = cv.imread(TestImread.filename, 'Grayscale',true);
            validateattributes(im1, {'uint8'}, {'nonempty', 'ndims',2});

            im2 = cv.imread(TestImread.filename, 'Flags',0);
            validateattributes(im2, {'uint8'}, {'nonempty', 'ndims',2});

            assert(isequal(im1,im2), 'Images are not equal');
        end

        function test_read_any_depth_color
            im = cv.imread(TestImread.filename, ...
                'AnyDepth',true, 'AnyColor',true);
            validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});
        end

        function test_read_unchanged
            im1 = cv.imread(TestImread.filename, 'Unchanged',true);
            validateattributes(im1, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});

            im2 = cv.imread(TestImread.filename, 'Flags',-1);
            validateattributes(im2, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});

            assert(isequal(im1,im2), 'Images are not equal');
        end

        function test_flip_channels
            im1 = cv.imread(TestImread.filename, ...
                'Color',true, 'FlipChannels',true);
            im2 = cv.imread(TestImread.filename, ...
                'Color',true, 'FlipChannels',false);
            validateattributes(im1, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});
            validateattributes(im2, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});
            assert(isequal(im1, flipdim(im2,3)), 'Images are not equal');
        end

        function test_gdal
            % TODO
            im = cv.imread(TestImread.filename, 'GDAL',true);
            assert(~isempty(im)), 'Failed to read image';
        end

        function test_compare
            % OpenCV
            im1 = cv.imread(TestImread.filename, ...
                'AnyColor',true, 'AnyDepth',true);

            % MATLAB
            im2 = imread(TestImread.filename);

            % Compare
            % TODO: not guaranteed to pass for JPEG images!
            assert(isequal(im1, im2), 'Images are not equal');
        end

        function test_error_argnum
            try
                cv.imread();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_non_existant_file
            try
                cv.imread('non_existant_image.jpg');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
