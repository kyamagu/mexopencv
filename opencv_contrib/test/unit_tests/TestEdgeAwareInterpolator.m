classdef TestEdgeAwareInterpolator
    %TestEdgeAwareInterpolator

    methods (Static)
        function test_1
            imgL = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale1.png'), ...
                'Grayscale',true);
            imgR = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale2.png'), ...
                'Grayscale',true);

            ptsL = cv.goodFeaturesToTrack(imgL);
            ptsL = cat(1, ptsL{:});
            ptsR = ptsL + randi(5, size(ptsL), class(ptsL));
            %ptsR = cv.calcOpticalFlowPyrLK(imgL, imgR, ptsL);

            interpolator = cv.EdgeAwareInterpolator();
            interpolator.K = 128;
            flow = interpolator.interpolate(imgL, ptsL, imgR, ptsR);
            validateattributes(flow, {'single'}, {'3d', 'size',[size(imgL) 2]});
        end
    end

end
