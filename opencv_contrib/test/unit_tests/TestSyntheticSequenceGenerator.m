classdef TestSyntheticSequenceGenerator
    %TestSyntheticSequenceGenerator

    methods (Static)
        function test_1
            bg = imread(fullfile(mexopencv.root(), 'test', 'fruits.jpg'));
            fg = imread(fullfile(mexopencv.root(), 'test', 'img001.jpg'));
            fg = cv.resize(fg, [100, 100]);

            gen = cv.SyntheticSequenceGenerator(bg, fg);
            for i=1:5
                [frame, gtMask] = gen.getNextFrame();
            end
        end
    end

end
