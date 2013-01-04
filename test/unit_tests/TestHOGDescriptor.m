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
            hog.save('TestHOGDescriptor.xml');
            hog2 = cv.HOGDescriptor('TestHOGDescriptor.xml');
            assert(hog.GammaCorrection == hog2.GammaCorrection);
            if exist('TestHOGDescriptor.xml','file')
                delete TestHOGDescriptor.xml;
            end
        end
    end
    
end

