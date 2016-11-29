classdef TestDisparityWLSFilter
    %TestDisparityWLSFilter

    properties (Constant)
        imL = fullfile(mexopencv.root(),'test','aloeL.jpg');
        imR = fullfile(mexopencv.root(),'test','aloeR.jpg');
        imGT = fullfile(mexopencv.root(),'test','aloeGT.png');
    end

    methods (Static)
        function test_filter_no_conf
            imgL = cv.imread(TestDisparityWLSFilter.imL, ...
                'Grayscale',true, 'ReduceScale',4);
            imgR = cv.imread(TestDisparityWLSFilter.imR, ...
                'Grayscale',true, 'ReduceScale',4);

            matcher = cv.StereoBM();
            dispL = matcher.compute(imgL, imgR);

            wls = cv.DisparityWLSFilter(false);
            wls.SigmaColor = 1;
            out = wls.filter(dispL, [], imgL);
            validateattributes(out, {class(dispL)}, {'size',size(dispL)});

            conf_map = wls.getConfidenceMap();
            assert(isempty(conf_map));

            roi = wls.getROI();
            validateattributes(roi, {'numeric'}, ...
                {'vector', 'integer', 'numel',4});
        end

        function test_filter_conf
            imgL = cv.imread(TestDisparityWLSFilter.imL, ...
                'Color',true, 'ReduceScale',4);
            imgR = cv.imread(TestDisparityWLSFilter.imR, ...
                'Color',true, 'ReduceScale',4);

            matcherL = cv.StereoSGBM();
            matcherR = cv.DisparityWLSFilter.createRightMatcher(matcherL);
            dispL = matcherL.compute(imgL, imgR);
            dispR = matcherR.compute(imgR, imgL);

            wls = cv.DisparityWLSFilter(matcherL);
            wls.SigmaColor = 1;
            out = wls.filter(dispL, dispR, imgL, 'RightView',imgR);
            validateattributes(out, {class(dispL)}, {'size',size(dispL)});

            conf_map = wls.getConfidenceMap();
            validateattributes(conf_map, {'single'}, ...
                {'size',size(out), '>=',0, '<=',255});

            roi = wls.getROI();
            validateattributes(roi, {'numeric'}, ...
                {'vector', 'integer', 'numel',4});
        end

        function test_create_matcher
            for i=1:2
                if i==1
                    matcherL = cv.StereoBM();
                else
                    matcherL = cv.StereoSGBM();
                end
                matcherR = cv.DisparityWLSFilter.createRightMatcher(matcherL);
                assert(isobject(matcherR) && isscalar(matcherR));
                assert(isa(matcherR, class(matcherL)));
            end
        end

        function test_ground_truth
            imgL = cv.imread(TestDisparityWLSFilter.imL, 'Grayscale',true);
            imgR = cv.imread(TestDisparityWLSFilter.imR, 'Grayscale',true);
            matcher = cv.StereoBM();
            disparity = matcher.compute(imgL, imgR);

            GT = cv.DisparityWLSFilter.readGT(TestDisparityWLSFilter.imGT);
            validateattributes(GT, {'int16'}, ...
                {'2d', 'nonempty', 'size',size(disparity)});

            viz = cv.DisparityWLSFilter.getDisparityVis(GT);
            validateattributes(viz, {'uint8'}, {'size',size(GT)})

            mse = cv.DisparityWLSFilter.computeMSE(GT, disparity);
            validateattributes(mse, {'double'}, ...
                {'scalar', 'positive', 'finite'});

            prcnt = cv.DisparityWLSFilter.computeBadPixelPercent(GT, disparity);
            validateattributes(prcnt, {'double'}, ...
                {'scalar', '>=',0, '<=',100});
        end
    end

end
