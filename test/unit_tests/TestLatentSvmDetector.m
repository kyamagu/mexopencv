classdef TestLatentSvmDetector
    %TestLatentSvmDetector
    properties (Constant)
    end
    
    methods (Static)
    	function test_1
            p = fileparts(fileparts(mfilename('fullpath')));
            im = imread(fullfile(p,'cat.jpg'));
            detector = cv.LatentSvmDetector(fullfile(p,'cat.xml'));
            d = detector.detect(im);
            assert(numel(d)>0);
        end
    end
    
end

