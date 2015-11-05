classdef TestSuperResolution
    %TestSuperResolution

    methods (Static)
        function test_1
            if true
                filename = which('shuttle.avi');  % 512x288 ~ 120 frames
                sz = [288 512 3];
            else
                filename = get_car_video();
            end
            if isempty(filename)
                disp('SKIP')
                return
            end

            superres = cv.SuperResolution();
            superres.setOpticalFlow('FarnebackOpticalFlow', ...
                'WindowSize',11, 'LevelsNumber',3);
            superres.setInput('Video', filename);
            superres.Scale = 2;
            superres.Iterations = 3;
            frame = superres.nextFrame();  % NOTE: takes a few seconds!
            validateattributes(frame, {'uint8'}, {'3d', 'nonempty', ...
                'size',[(sz(1:2)-superres.KernelSize)*superres.Scale sz(3)]});
        end

        function test_2
            superres = cv.SuperResolution();
            superres.Iterations = 100;
            assert(isequal(superres.Iterations,100));
            superres.setOpticalFlow('FarnebackOpticalFlow', ...
                'WindowSize',11, 'LevelsNumber',3);
            optflow = superres.getOpticalFlow();
            validateattributes(optflow, {'struct'}, {'scalar'});
            assert(isequal(optflow.WindowSize,11) && ...
                isequal(optflow.LevelsNumber,3));
        end
    end
end

function fname = get_car_video()
    fname = fullfile(mexopencv.root(),'test','car.avi');
    if ~exist(fname, 'file')
        % download video from Github
        url = 'https://cdn.rawgit.com/Itseez/opencv_extra/3.0.0/testdata/superres/car.avi';
        disp('Downloading video...')
        urlwrite(url, fname);
    end
end
