classdef TestHOGDescriptor
    %TestHOGDescriptor
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            hog = cv.HOGDescriptor();
            hog.compute(im);
            hog.detectMultiScale(im);
        end
        
        function test_2
            hog = cv.HOGDescriptor();
            hog.GammaCorrection = false;
            fname = [tempname '.xml'];
            hog.save(fname);
            hog2 = cv.HOGDescriptor(fname);
            assert(hog.GammaCorrection == hog2.GammaCorrection);
            if exist(fname,'file')
                delete(fname);
            end
        end
    end
    
end

