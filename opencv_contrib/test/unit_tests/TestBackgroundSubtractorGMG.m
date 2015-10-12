classdef TestBackgroundSubtractorGMG
    %TestBackgroundSubtractorGMG

    methods (Static)
        function test_1
            bs = cv.BackgroundSubtractorGMG();
            bs.NumFrames = 100;
            for i=1:10
                frame = randi(255, [100 100 3], 'uint8');
                fgmask = bs.apply(frame, 'LearningRate',-1);
                validateattributes(fgmask, {'logical'}, {'size',[100 100]});
            end
            fgmask = bs.apply(frame, 'LearningRate',0);
            if false
                %TODO: getBackgroundImage always empty for GMG
                bg = bs.getBackgroundImage();
                validateattributes(bg, {'uint8'}, {'size',[100 100 3]});
            end
        end
    end

end
