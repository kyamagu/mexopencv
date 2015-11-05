classdef TestLSVMDetector
    %TestLSVMDetector
    properties (Constant)
        xmlfile = fullfile(mexopencv.root(),'test','cat.xml');
        im = fullfile(mexopencv.root(),'test','cat.jpg');
    end

    methods (Static)
        function test_1
            detector = cv.LSVMDetector(TestLSVMDetector.xmlfile);
            assert(~detector.isEmpty());
            assert(detector.getClassCount() == 1);
            assert(iscellstr(detector.getClassNames()));

            img = imread(TestLSVMDetector.im);
            objects = detector.detect(img);
            if ~isempty(objects)
                validateattributes(objects, {'struct'}, {'vector'});
                arrayfun(@(S) validateattributes(S.rect, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), objects);
                arrayfun(@(S) validateattributes(S.score, {'numeric'}, ...
                    {'scalar'}), objects);
                arrayfun(@(S) validateattributes(S.class, {'char'}, ...
                    {'vector', 'row'}), objects);
            end
        end

        function test_2
            detector = cv.LSVMDetector(...
                {TestLSVMDetector.xmlfile, TestLSVMDetector.xmlfile}, ...
                {'cat1', 'cat2'});
            assert(~detector.isEmpty());
            assert(detector.getClassCount() == 2);
            assert(iscellstr(detector.getClassNames()));

            img = imread(TestLSVMDetector.im);
            objects = detector.detect(img);
            if ~isempty(objects)
                validateattributes(objects, {'struct'}, {'vector'});
                arrayfun(@(S) validateattributes(S.rect, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), objects);
                arrayfun(@(S) validateattributes(S.score, {'numeric'}, ...
                    {'scalar'}), objects);
                arrayfun(@(S) validateattributes(S.class, {'char'}, ...
                    {'vector', 'row'}), objects);
            end
        end
    end

end
