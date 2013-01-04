classdef TestLatentSvmDetector
    %TestLatentSvmDetector
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            detector = cv.LatentSvmDetector(fullfile(mexopencv.root(),'test','cat.xml'));
            d = detector.detect(im);
            assert(numel(d)>0);
        end
    end
    
end

