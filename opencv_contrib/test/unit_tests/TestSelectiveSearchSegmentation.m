classdef TestSelectiveSearchSegmentation
    %TestSelectiveSearchSegmentation

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','balloon.jpg'), ...
                'Color',true, 'ReduceScale',2);

            for s=1:3
                gs = cv.SelectiveSearchSegmentation();
                gs.setBaseImage(img);

                switch s
                    case 1
                        gs.switchToSingleStrategy();
                    case 2
                        gs.switchToSelectiveSearchFast();
                    case 3
                        gs.switchToSelectiveSearchQuality();
                end

                rects = gs.process();
                if ~isempty(rects)
                    validateattributes(rects, {'numeric'}, ...
                        {'2d', 'size',[NaN 4], 'integer'});
                end
            end
        end
    end

end
