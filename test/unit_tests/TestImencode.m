classdef TestImencode
    %TestImencode
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_encode
            frmts = TestImwrite.getFormats();
            for i=1:numel(frmts)
                try
                    buf = cv.imencode(frmts(i).ext, TestImencode.im, ...
                        frmts(i).opts{:});
                    validateattributes(buf, {'uint8'}, {'vector', 'nonempty'});
                catch ME
                    %TODO: some codecs are not available on all platforms
                    fprintf('SKIPPED: %s (%s)\n', frmts(i).name, frmts(i).ext);
                    continue;
                end
            end
        end

        function test_options
            buf = cv.imencode('.png', TestImencode.im, 'PngCompression',9);
            validateattributes(buf, {'uint8'}, {'vector', 'nonempty'});

            buf = cv.imencode('.jpg', TestImencode.im, 'JpegQuality',75);
            validateattributes(buf, {'uint8'}, {'vector', 'nonempty'});
        end

        function test_verify_lossless_png
            % encode image (in lossless PNG format)
            buf = cv.imencode('.png', TestImencode.im);
            validateattributes(buf, {'uint8'}, {'vector', 'nonempty'});

            % write bytes to disk, and read back image
            img = TestImencode.writeBytesAsImage(buf, '.png');

            % compare against original image
            assert(isequal(img, TestImencode.im), 'Images are not equal');
        end

        function test_flip_channels
            buf = cv.imencode('.png', TestImencode.im, 'FlipChannels',false);
            validateattributes(buf, {'uint8'}, {'vector', 'nonempty'});
            im1 = TestImencode.writeBytesAsImage(buf, '.png');

            buf = cv.imencode('.png', TestImencode.im, 'FlipChannels',true);
            validateattributes(buf, {'uint8'}, {'vector', 'nonempty'});
            im2 = TestImencode.writeBytesAsImage(buf, '.png');

            assert(isequal(im1, flipdim(im2,3)));
        end

        function test_error_argum
            try
                cv.imencode();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_param_value
            try
                cv.imencode('.jpg', TestImencode.im, 'JpegQuality',-1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_unrecognized_extension
            %TODO: crashes Octave
            if mexopencv.isOctave()
                disp('SKIP');
                return;
            end

            try
                cv.imencode('.foobar', TestImencode.im);
                throw('UnitTest:Fail');
            catch e
                %TODO: C++ exception thrown by OpenCV
                %assert(strcmp(e.identifier,'MATLAB:unexpectedCPPexception'));
            end
        end
    end

    %% helper functions
    methods (Static)
        function img = writeBytesAsImage(buf, ext)
            filename = [tempname() ext];
            cObj = onCleanup(@() TestImencode.deleteFile(filename));

            fid = fopen(filename, 'wb');
            fwrite(fid, buf, 'uint8');
            fclose(fid);

            img = imread(filename);
        end

        function deleteFile(fname)
            if exist(fname, 'file') == 2
                delete(fname);
            end
        end
    end

end
