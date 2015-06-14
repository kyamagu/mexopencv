classdef TestLSVMDetector
    %TestLSVMDetector
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            detector = cv.LSVMDetector(fullfile(mexopencv.root(),'test','cat.xml'));
            d = detector.detect(im);
            assert(~isempty(d));
        end
    end
    
end

