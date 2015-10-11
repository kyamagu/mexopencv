classdef TestImwrite
    %TestImwrite
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
    end

    methods (Static)
        function test_write_jpeg
            filename = [tempname '.jpg'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im, ....
                'JpegQuality',90, 'JpegProgressive',false, ...
                'JpegOptimize',false, 'JpegResetInterval',0, ...
                'JpegLumaQuality',0, 'JpegChromaQuality',0);
            assert(exist(filename,'file')==2, 'Failed to write JPEG');
        end

        function test_write_png
            filename = [tempname '.png'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im, ...
                'PngCompression',9, 'PngStrategy','RLE');
            assert(exist(filename,'file')==2, 'Failed to write PNG');
        end

        function test_write_pxm
            filename = [tempname '.ppm'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im, 'PxmBinary',false);
            assert(exist(filename,'file')==2, 'Failed to write PPM');
        end

        function test_write_tiff
            filename = [tempname '.tif'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write TIFF');
        end

        function test_write_bmp
            filename = [tempname '.bmp'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write BMP');
        end

        function test_write_webp
            filename = [tempname '.webp'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write WebP');
        end

        function test_write_sunras
            filename = [tempname '.ras'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write Sun Raster');
        end

        function test_write_jpeg2000
            filename = [tempname '.jp2'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write JPEG-2000');
        end

        function test_write_exr
            filename = [tempname '.exr'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            %TODO
            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write OpenEXR');
        end

        function test_write_hdr
            filename = [tempname '.hdr'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            %TODO
            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write Radiance HDR');
        end

        function test_verify_lossless_png
            filename = [tempname '.png'];
            cObj = onCleanup(@() TestImwrite.deleteFile(filename));

            % write image to PNG file (lossless)
            cv.imwrite(filename, TestImwrite.im);
            assert(exist(filename,'file')==2, 'Failed to write PNG');

            % read back image from disk
            img = imread(filename);

            % compare
            assert(isequal(img, TestImwrite.im), 'Images are not equal');
        end

        function test_flip_channels
            filename1 = [tempname '.png'];
            filename2 = [tempname '.png'];
            cObj1 = onCleanup(@() TestImwrite.deleteFile(filename1));
            cObj2 = onCleanup(@() TestImwrite.deleteFile(filename2));

            cv.imwrite(filename1, TestImwrite.im, 'FlipChannels',false);
            cv.imwrite(filename2, TestImwrite.im, 'FlipChannels',true);
            im1 = imread(filename1);
            im2 = imread(filename2);
            assert(isequal(im1, flipdim(im2,3)), 'FlipChannels option failed');
        end

        function test_error_argnum
            try
                cv.imwrite();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_param_value
            try
                cv.imwrite('image.jpg', TestImwrite.im, 'JpegQuality',-1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_unrecognized_extension
            try
                cv.imwrite('image.foobar', TestImwrite.im);
                throw('UnitTest:Fail');
            catch e
                %TODO: C++ exception thrown by OpenCV
                %assert(strcmp(e.identifier,'MATLAB:unexpectedCPPexception'));
            end
        end
    end

    %% helper functions
    methods (Static)
        function deleteFile(fname)
            if exist(fname, 'file') == 2
                delete(fname);
            end
        end
    end

end
