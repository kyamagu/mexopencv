classdef TestCascadeClassifier
    %TestCascadeClassifier
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = imread(fullfile(cv_root(),'test','img001.jpg'));
            cc = cv.CascadeClassifier(fullfile(cv_root(),'test','haarcascade_frontalface_alt2.xml'));
            cc.detect(im);
        end
    end
    
end

