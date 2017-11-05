classdef TestStaticSaliencyFineGrained
    %TestStaticSaliencyFineGrained

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','balloon.jpg'));

            saliency = cv.StaticSaliencyFineGrained();

            saliencyMap = saliency.computeSaliency(img);
            validateattributes(saliencyMap, {'uint8'}, ...
                {'size',[size(img,1) size(img,2)]});

            binaryMap = saliency.computeBinaryMap(saliencyMap);
            validateattributes(binaryMap, {'uint8'}, ...
                {'size',[size(img,1) size(img,2)]});
            assert(all(ismember(unique(binaryMap(:)), [0 255])));
        end
    end

end
