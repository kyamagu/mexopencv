classdef TestBackgroundSubtractorMOG2
    %TestBackgroundSubtractorMOG2

    methods (Static)
        function test_1
            frame = randi([0 255], [50 50 3], 'uint8');
            sz = size(frame);

            bs = cv.BackgroundSubtractorMOG2('History',5);
            for i=1:10
                fgmask = bs.apply(frame, 'LearningRate',-1);
            end

            frame(1:10,1:10,:) = 255;
            fgmask = bs.apply(frame, 'LearningRate',0);
            validateattributes(fgmask, {'uint8'}, {'size',sz(1:2)});
            assert(numel(unique(fgmask)) <= 3);  % 0=bg, 255=fg, 127=mask

            bg = bs.getBackgroundImage();
            validateattributes(bg, {'uint8'}, {'size',sz});
        end
    end

end
