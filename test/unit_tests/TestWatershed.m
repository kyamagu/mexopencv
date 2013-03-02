classdef TestWatershed
    %TestWatershed
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            im = TestWatershed.img;
            bbox = [100,100,200,320]; % [x,y,w,h]
            marker = zeros(size(im,1),size(im,2),'int32');
            marker(bbox(2):(bbox(2)+bbox(4)-1),bbox(1):(bbox(1)+bbox(3)-1)) = 1;
            marker = cv.watershed(im,marker);
        end
        
        function test_error_1
            try
                cv.watershed();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

