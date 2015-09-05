classdef TestImdecode
    %TestImdecode
    properties (Constant)
        filename = fullfile(mexopencv.root(),'test','RubberWhale1.png');
    end

    methods (Static)
        function test_decode
            buf = TestImdecode.readBytes(TestImdecode.filename);
            im = cv.imdecode(buf);
            validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});
        end

        function test_decode_unchanged
            buf = TestImdecode.readBytes(TestImdecode.filename);

            im = cv.imdecode(buf, 'Unchanged',true);
            validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});

            im = cv.imdecode(buf, 'Flags',-1);
            validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});
        end

        function test_decode_color
            buf = TestImdecode.readBytes(TestImdecode.filename);

            im = cv.imdecode(buf, 'Color',true);
            validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});

            im = cv.imdecode(buf, 'Flags',1);
            validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',3, 'size',[NaN NaN 3]});
        end

        function test_decode_grayscale
            buf = TestImdecode.readBytes(TestImdecode.filename);

            im = cv.imdecode(buf, 'Grayscale',true);
            validateattributes(im, {'uint8'}, {'nonempty', 'ndims',2});

            im = cv.imdecode(buf, 'Flags',0);
            validateattributes(im, {'uint8'}, {'nonempty', 'ndims',2});
        end

        function test_flip_channels
            buf = TestImdecode.readBytes(TestImdecode.filename);
            im1 = cv.imdecode(buf, 'Color',true, 'FlipChannels',true);
            im2 = cv.imdecode(buf, 'Color',true, 'FlipChannels',false);
            assert(isequal(im1, flipdim(im2,3)));
        end

        function test_compare
            % decode bytes
            buf = TestImdecode.readBytes(TestImdecode.filename);
            im1 = cv.imdecode(buf, 'Flags',-1);

            % read original image
            im2 = imread(TestImdecode.filename);

            % compare
            % TODO: not guaranteed to pass for JPEG images!!
            assert(isequal(im1,im2), 'Images are not equal');
        end

        function test_error_argnum
            try
                cv.imdecode();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_buf
            try
                cv.imdecode(ones(1,100,'uint8'));
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

    %% helper functions
    methods (Static)
        function buf = readBytes(filename)
            fid = fopen(filename, 'rb');
            buf = fread(fid, Inf, '*uint8');
            fclose(fid);
        end
    end

end
