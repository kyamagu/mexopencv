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
                error('mexopencv:testskip', 'missing data');
            end

            superres = cv.SuperResolution();
            superres.setOpticalFlow('FarnebackOpticalFlow', ...
                'WindowSize',11, 'LevelsNumber',2, 'Iterations',2);
            superres.setInput('Video', filename);
            superres.Scale = 2;
            superres.Iterations = 2;
            superres.TemporalAreaRadius = 2;
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
    if exist(fname, 'file') ~= 2
        % download video from Github
        url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.2.0/testdata/superres/car.avi';
        urlwrite(url, fname);
    end
end
