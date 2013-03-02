classdef TestCascadeClassifier
    %TestCascadeClassifier
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            cc = cv.CascadeClassifier(fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt2.xml'));
            cc.detect(im);
        end
    end
    
end

