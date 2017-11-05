classdef TestStaticSaliencySpectralResidual
    %TestStaticSaliencySpectralResidual

    methods (Static)
        function test_1
            saliency = cv.StaticSaliencySpectralResidual();
            saliency.ImageWidth = 64;
            saliency.ImageHeight = 64;

            img = imread(fullfile(mexopencv.root(),'test','balloon.jpg'));
            saliencyMap = saliency.computeSaliency(img);
            validateattributes(saliencyMap, {'single'}, ...
                {'size',[size(img,1) size(img,2)], '>=',0, '<=',1});

            binaryMap = saliency.computeBinaryMap(saliencyMap);
            validateattributes(binaryMap, {'uint8'}, ...
                {'size',[size(img,1) size(img,2)]});
            assert(all(ismember(unique(binaryMap(:)), [0 255])));
        end
    end

end
