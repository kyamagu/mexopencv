classdef TestBrightEdges
    %TestBrightEdges

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','balloon.jpg'));
            out = cv.BrightEdges(img, 'Contrast',1);
            validateattributes(out, {'uint8'}, ...
                {'size',[size(img,1) size(img,2)]});
        end
    end

end
