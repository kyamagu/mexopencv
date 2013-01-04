classdef TestMatchTemplate
    %TestMatchTemplate
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            im = rgb2gray(TestMatchTemplate.img);
            tmpl = im(120:150,180:210,:);
            result = cv.matchTemplate(im,tmpl);
        end
        
        function test_error_1
            try
                cv.matchTemplate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

