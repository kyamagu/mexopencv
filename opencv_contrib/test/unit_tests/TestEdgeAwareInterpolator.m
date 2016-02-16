classdef TestEdgeAwareInterpolator
    %TestEdgeAwareInterpolator
    properties (Constant)
        imL = fullfile(mexopencv.root(),'test','RubberWhale1.png');
        imR = fullfile(mexopencv.root(),'test','RubberWhale2.png');
    end

    methods (Static)
        function test_1
            imgL = cv.imread(TestEdgeAwareInterpolator.imL, 'Grayscale',true);
            imgR = cv.imread(TestEdgeAwareInterpolator.imR, 'Grayscale',true);

            ptsL = cv.goodFeaturesToTrack(imgL);
            %ptsR = cv.calcOpticalFlowPyrLK(imgL, imgR, ptsL);
            ptsR = cellfun(@(p) p+randi(5, [1,2]), ptsL, 'Uniform',false);

            interpolator = cv.EdgeAwareInterpolator();
            interpolator.K = 128;
            flow = interpolator.interpolate(imgL, ptsL, imgR, ptsR);
            validateattributes(flow, {'single'}, {'size',[size(imgL) 2]});
        end
    end

end
