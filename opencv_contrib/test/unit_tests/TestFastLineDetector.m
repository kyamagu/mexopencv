classdef TestFastLineDetector
    %TestFastLineDetector

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','blox.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);

            obj = cv.FastLineDetector();
            lines = obj.detect(img);
            validateattributes(lines, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',4, 'real'}), lines);

            img = repmat(img, [1 1 3]);
            out = obj.drawSegments(img, lines);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end
    end

end
