classdef TestVideoWriter
    %TestVideoWriter

    methods (Static)
        function test_1
            % we use "Microsoft Video 1" codec (Windows only)
            if ~ispc
                disp('SKIP')
                return
            end

            filename = [tempname '.avi'];
            cObj = onCleanup(@() TestVideoWriter.deleteFile(filename));

            w = 640; h = 480;
            img = zeros([h w 3], 'uint8');
            vid = cv.VideoWriter(filename, [w h], ...
                'FourCC','MSVC', 'Color',true, 'FPS',25);
            for x=0:10:255
                img(:,:,1) = x;
                vid.write(img);
            end
            vid.release();

            % check video was created
            f = dir(filename);
            assert(~isempty(f) && f.bytes>0, 'Failed to create video');

            % verify video
            %TODO: MMFILEINFO not yet implemented in Octave
            if ~mexopencv.isOctave()
                info = mmfileinfo(filename);
                assert(info.Video.Width == w && info.Video.Height == h);
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
