classdef TestApplyColorMap
    %TestApplyColorMap

    methods (Static)
        function test_rgb
            src = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            dst = cv.applyColorMap(src, 'Jet');
            validateattributes(dst, {'uint8'}, {'ndims',3, 'size',size(src)});
        end

        function test_gray
            %src = im2uint8(mat2gray(peaks(500)));
            src = peaks(500);
            src = uint8(255 * (src - min(src(:))) ./ (max(src(:)) - min(src(:))));
            dst = cv.applyColorMap(src, 'Jet');
            validateattributes(dst, {'uint8'}, {'ndims',3, 'size',[size(src) 3]});
        end

        function test_colormaps
            %src = im2uint8(mat2gray(peaks(500)));
            src = peaks(500);
            src = uint8(255 * (src - min(src(:))) ./ (max(src(:)) - min(src(:))));
            cmaps = {'Autumn', 'Bone', 'Jet', 'Winter', 'Rainbow', 'Ocean', ...
                'Summer', 'Spring', 'Cool', 'Hsv', 'Pink', 'Hot', 'Parula'};
            for i=1:numel(cmaps)
                dst = cv.applyColorMap(src, cmaps{i});
            end
        end

        function test_error_1
            try
                cv.applyColorMap();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
