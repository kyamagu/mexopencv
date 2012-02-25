classdef TestCascadeClassifier
    %TestCascadeClassifier
    properties (Constant)
    end
    
    methods (Static)
    	function test_1
            p = fileparts(fileparts(mfilename('fullpath')));
            im = imread([p,filesep,'img001.jpg']);
            cc = cv.CascadeClassifier([p,filesep,'haarcascade_frontalface_alt2.xml']);
            cc.detect(im);
        end
    end
    
end

