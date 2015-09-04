classdef TestBackgroundSubtractorMOG2
    %TestBackgroundSubtractorMOG2

    methods (Static)
        function test_1
            bs = cv.BackgroundSubtractorMOG2();
            bs.History = 100;
            for i=1:10
                frame = randi(255, [100 100 3], 'uint8');
                fgmask = bs.apply(frame, 'LearningRate',-1);
                validateattributes(fgmask, {'logical'}, {'size',[100 100]});
            end
            fgmask = bs.apply(frame, 'LearningRate',0);
            bg = bs.getBackgroundImage();
            validateattributes(bg, {'uint8'}, {'size',[100 100 3]});
        end
    end

end
