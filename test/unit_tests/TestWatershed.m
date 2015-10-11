classdef TestWatershed
    %TestWatershed

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            [H,W,~] = size(img);

            bbox = [100,100,200,320]; % [x,y,w,h]
            markers = zeros(H, W, 'int32');
            markers(bbox(2):(bbox(2)+bbox(4)-1), bbox(1):(bbox(1)+bbox(3)-1)) = 1;

            markers = cv.watershed(img, markers);
            validateattributes(markers, {'int32'}, {'2d', 'size',[H W], '>=',-1});
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
