classdef TestLSDDetector
    %TestLSDDetector

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'angle', 'class_id', 'octave', 'pt', 'response', ...
            'size', 'startPoint', 'endPoint', 'startPointInOctave', ...
            'endPointInOctave', 'lineLength', 'numOfPixels'};
    end

    methods (Static)
        function test_detect_img
            obj = cv.LSDDetector();
            img = imread(TestLSDDetector.im);

            klines = obj.detect(img, 'Scale',2, 'NumOctaves',1);
            validateattributes(klines, {'struct'}, {'vector'});
            assert(all(ismember(TestLSDDetector.kfields, fieldnames(klines))));
        end

        function test_detect_imgset
            img = imread(TestLSDDetector.im);
            imgs = {img, img};
            obj = cv.LSDDetector();

            klines = obj.detect(imgs, 'Scale',2, 'NumOctaves',1);
            validateattributes(klines, {'cell'}, ...
                {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, ...
                {'vector'}), klines);
            cellfun(@(kpt) assert(all(ismember(TestLSDDetector.kfields, ...
                fieldnames(kpt)))), klines);
        end

        function test_detect_mask
            img = imread(TestLSDDetector.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.LSDDetector();

            klines = obj.detect(img, 'Mask',mask);
            validateattributes(klines, {'struct'}, {'vector'});
            assert(all(ismember(TestLSDDetector.kfields, fieldnames(klines))));
        end
    end

end
