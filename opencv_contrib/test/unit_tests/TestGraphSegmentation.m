classdef TestGraphSegmentation
    %TestGraphSegmentation

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            gs = cv.GraphSegmentation('K',300);
            assert(isequal(gs.K,300));
            L = gs.processImage(img);
            validateattributes(L, {'int32'}, ...
                {'size',[size(img,1) size(img,2)]});
        end
    end

end
