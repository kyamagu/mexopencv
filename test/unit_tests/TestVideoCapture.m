classdef TestVideoCapture
    %TestVideoCapture

    methods (Static)
        function test_mp4
            % AVC1
            filename = which('xylophone.mp4');
            if isempty(filename)
                disp('SKIP')
                return
            end
            TestVideoCapture.checkVideoFile(filename);
        end

        function test_mpg
            % MPEG1
            filename = which('xylophone.mpg');
            if isempty(filename)
                disp('SKIP')
                return
            end
            TestVideoCapture.checkVideoFile(filename);
        end

        function test_avi
            % MJPG
            filename = which('shuttle.avi');
            if isempty(filename)
                disp('SKIP')
                return
            end
            TestVideoCapture.checkVideoFile(filename);
        end

        function test_img_sequence
            filename = fullfile(mexopencv.root(),'test','left%02d.jpg');
            TestVideoCapture.checkVideoFile(filename);
        end

        function test_camera
            %TODO
            if false
                cap = cv.VideoCapture(0);
                pause(2);
                assert(cap.isOpened());
                img = cap.read();
                assert(~isempty(img));
                cap.release();
            else
                disp('SKIP')
                return
            end
        end
    end

    %% helper functions
    methods (Static)
        function checkVideoFile(filename)
            cap = cv.VideoCapture(filename);
            assert(cap.isOpened());
            for i=1:cap.FrameCount
                img = cap.read();
                assert(~isempty(img));
            end
            cap.release();
        end
    end

end
