classdef TestTwoPassStabilizer
    %TestTwoPassStabilizer

    methods (Static)
        function test_0
            stab = cv.TwoPassStabilizer();
            stab.getLog();
            stab.getFrameSource();
            stab.getDeblurer();
            stab.getMotionEstimator();
            stab.getInpainter();
            stab.getMotionStabilizer();
            stab.getWobbleSuppressor();
        end

        function test_1
            %TODO
            if true
                error('mexopencv:testskip', 'todo');
            end

            stab = cv.TwoPassStabilizer();
            stab.setFrameSource('VideoFileSource', which('shaky_car.avi'));
            for i=1:10
                frame = stab.nextFrame();
            end
        end
    end

end
