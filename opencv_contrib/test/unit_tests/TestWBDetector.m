classdef TestWBDetector
    %TestWBDetector

    methods (Static)
        function test_1
            detector = cv.WBDetector();
        end

        function test_2
            %TODO: we need a test set
            %TODO: https://github.com/opencv/opencv_contrib/issues/633
            %TODO: https://github.com/opencv/opencv_contrib/issues/741
            if true
                error('mexopencv:testskip', 'todo');
            end

            detector = cv.WBDetector();
            detector.train('/path/to/pos', '/path/to/neg');    %TODO
            img = cv.imread('path/to/img', 'Grayscale',true);  %TODO
            [bboxes,conf] = detector.detect(img);
            validateattributes(bboxes, {'cell'}, {'vector'});
            cellfun(@(r) validateattributes(r, {'numeric'}, ...
                {'vector', 'integer', 'numel',4}), bboxes);
            validateattributes(conf, {'numeric'}, ...
                {'vector', 'numel',numel(bboxes)});
        end
    end

end
