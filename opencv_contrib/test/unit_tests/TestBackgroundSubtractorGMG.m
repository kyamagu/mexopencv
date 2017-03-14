classdef TestBackgroundSubtractorGMG
    %TestBackgroundSubtractorGMG

    methods (Static)
        function test_1
            bs = cv.BackgroundSubtractorGMG();
            bs.NumFrames = 5;
            for i=1:10
                frame = randi(255, [50 50 3], 'uint8');
                fgmask = bs.apply(frame, 'LearningRate',-1);
                validateattributes(fgmask, {'logical'}, {'size',[50 50]});
            end
            fgmask = bs.apply(frame, 'LearningRate',0);
            if false
                %TODO: getBackgroundImage always empty for GMG
                bg = bs.getBackgroundImage();
                validateattributes(bg, {'uint8'}, {'size',[50 50 3]});
            end
        end
    end

end
