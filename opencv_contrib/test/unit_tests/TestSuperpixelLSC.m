classdef TestSuperpixelLSC
    %TestSuperpixelLSC

    methods (Static)
        function test_1
            %TODO: OpenCV's SuperpixelLSC is buggy;
            % sometimes crashes MATLAB when called repeatedly
            if true
                error('mexopencv:testskip', 'todo');
            end

            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), ...
                'Color',true, 'ReduceScale',2);
            lab = cv.cvtColor(img, 'RGB2Lab');

            superpix = cv.SuperpixelLSC(lab, 'RegionSize',20);
            superpix.iterate();
            superpix.enforceLabelConnectivity();

            num = superpix.getNumberOfSuperpixels();
            validateattributes(num, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative'});

            L = superpix.getLabels();
            validateattributes(L, {'int32'}, ...
                {'size',[size(img,1) size(img,2)], '>=',0, '<',num});

            mask = superpix.getLabelContourMask();
            validateattributes(mask, {'logical'}, ...
                {'size',[size(img,1) size(img,2)]});
        end
    end

end
