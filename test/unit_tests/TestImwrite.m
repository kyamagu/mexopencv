classdef TestImwrite
    %TestImwrite
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
    end

    methods (Static)
        function test_write
            frmts = TestImwrite.getFormats();
            for i=1:numel(frmts)
                filename = [tempname frmts(i).ext];
                cObj = onCleanup(@() TestImwrite.deleteFile(filename));
                try
                    cv.imwrite(filename, TestImwrite.im, frmts(i).opts{:});
                    assert(exist(filename,'file')==2, ...
                        'Failed to write %s', frmts(i).name);
                catch ME
                    %TODO: some codecs are not available on all platforms
                    fprintf('SKIPPED: %s (%s)\n', frmts(i).name, frmts(i).ext);
                    continue;
                end
            end
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
            %TODO: crashes Octave
            if mexopencv.isOctave()
                disp('SKIP');
                return;
            end

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

        function frmts = getFormats()
            frmts = repmat(struct('name','', 'ext','', 'opts',{{}}), 10, 1);
            frmts(1).name = 'JPEG';
            frmts(1).ext = '.jpg';
            frmts(1).opts = {'JpegQuality',90, 'JpegProgressive',false, ...
                'JpegOptimize',false, 'JpegResetInterval',0, ...
                'JpegLumaQuality',0, 'JpegChromaQuality',0};
            frmts(2).name = 'PNG';
            frmts(2).ext = '.png';
            frmts(2).opts = {'PngCompression',9, 'PngStrategy','RLE'};
            frmts(3).name = 'PPM';
            frmts(3).ext = '.ppm';
            frmts(3).opts = {'PxmBinary',false};
            frmts(4).name = 'TIFF';
            frmts(4).ext = '.tif';
            frmts(5).name = 'BMP';
            frmts(5).ext = '.bmp';
            frmts(6).name = 'WebP';
            frmts(6).ext = '.webp';
            frmts(7).name = 'Sun Raster';
            frmts(7).ext = '.ras';
            frmts(8).name = 'JPEG-2000';
            frmts(8).ext = '.jp2';
            frmts(9).name = 'OpenEXR';
            frmts(9).ext = '.exr';
            frmts(10).name = 'Radiance HDR';
            frmts(10).ext = '.hdr';
        end
    end

end
