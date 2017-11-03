classdef TestVideoWriter
    %TestVideoWriter

    methods (Static)
        function test_1
            % we use "Microsoft Video 1" codec (Windows only)
            if ~ispc() || mexopencv.isOctave()
                error('mexopencv:testskip', 'codecs');
            end

            filename = [tempname() '.avi'];
            cObj = onCleanup(@() TestVideoWriter.deleteFile(filename));

            w = 640; h = 480;
            img = zeros([h w 3], 'uint8');
            vid = cv.VideoWriter(filename, [w h], ...
                'FourCC','MSVC', 'Color',true, 'FPS',25);
            assert(vid.isOpened());
            for x=0:10:255
                img(:,:,1) = x;
                vid.write(img);
            end
            vid.release();

            % check video was created
            f = dir(filename);
            assert(~isempty(f) && f.bytes>0, 'Failed to create video');

            % verify video
            if ~mexopencv.isOctave()
                %HACK: MMFILEINFO not yet implemented in Octave
                info = mmfileinfo(filename);
                assert(info.Video.Width == w && info.Video.Height == h);
            end
        end

        function test_2
            % fourCC + extension
            if true
                % builtin MJPG encoder, should work across all systems
                codecs = {'MJPG' '.avi'};
            else
                %NOTE: these are some common codecs that worked on my Windows
                % machine, no guarantees elsewhere!
                codecs = { ...
                    'PIM1' '.mpg' ; ...
                    'MPG1' '.mpg' ; ...
                    'MSVC' '.avi' ; ...
                    'MJPG' '.avi' ; ...
                    'XVID' '.avi' ; ...
                    'WMV2' '.wmv' ; ...
                    'FLV1' '.flv' ; ...
                    'MP4V' '.mp4' ; ...
                    'MP42' '.mkv' ; ...
                };
            end
            w = 640; h = 480;
            for i=1:size(codecs,1)
                fname = [tempname() codecs{i,2}];
                cObj = onCleanup(@() TestVideoWriter.deleteFile(fname));
                try
                    vid = cv.VideoWriter(fname, [w h], 'FourCC',codecs{i,1});
                    assert(vid.isOpened());
                    for j=1:5, vid.write(randi([0 255], [h w 3], 'uint8')); end
                    vid.release();
                catch ME
                    %TODO: some codecs are not available on all platforms
                    %error('mexopencv:testskip', 'codecs %s (%s)', ...
                    %    codecs{i,1}, codecs{i,2});
                    continue;
                end
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
