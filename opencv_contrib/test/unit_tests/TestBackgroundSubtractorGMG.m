classdef TestBackgroundSubtractorGMG
    %TestBackgroundSubtractorGMG

    methods (Static)
        function test_1
            frame = randi([0 255], [50 50 3], 'uint8');
            sz = size(frame);

            bs = cv.BackgroundSubtractorGMG('InitializationFrames',5);
            for i=1:10
                fgmask = bs.apply(frame, 'LearningRate',-1);
            end

            frame(1:10,1:10,:) = 255;
            fgmask = bs.apply(frame, 'LearningRate',0);
            validateattributes(fgmask, {'uint8'}, {'size',sz(1:2)});
            assert(numel(unique(fgmask)) <= 2);  % 0=bg, 255=fg

            % getBackgroundImage not implemented for GMG, always returns empty
            %bg = bs.getBackgroundImage();
        end
    end

end
