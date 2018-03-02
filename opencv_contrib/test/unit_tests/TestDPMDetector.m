classdef TestDPMDetector
    %TestDPMDetector

    properties (Constant)
        %xmlfile = fullfile(mexopencv.root(),'test','inriaperson.xml');
        xmlfile = fullfile(mexopencv.root(),'test','cat.xml');
        im = fullfile(mexopencv.root(),'test','cat.jpg');
    end

    methods (Static)
        function test_cat
            download_cascade_model(TestDPMDetector.xmlfile);
            detector = cv.DPMDetector(TestDPMDetector.xmlfile);
            assert(~detector.isEmpty());
            assert(detector.getClassCount() == 1);
            assert(iscellstr(detector.getClassNames()));

            img = imread(TestDPMDetector.im);
            objects = detector.detect(img);
            validateattributes(objects, {'struct'}, {'vector'});
            if ~isempty(objects)
                arrayfun(@(S) validateattributes(S.rect, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), objects);
                arrayfun(@(S) validateattributes(S.score, {'numeric'}, ...
                    {'scalar'}), objects);
                arrayfun(@(S) validateattributes(S.class, {'char'}, ...
                    {'vector', 'row'}), objects);
            end
        end

        function test_multiple_models
            %TODO: Octave throws error:
            % (out of memory or dimension too large for Octave's index type)
            if mexopencv.isOctave()
                error('mexopencv:testskip', 'todo');
            end

            detector = cv.DPMDetector(...
                {TestDPMDetector.xmlfile, TestDPMDetector.xmlfile}, ...
                {'cat1', 'cat2'});
            assert(~detector.isEmpty());
            assert(detector.getClassCount() == 2);
            assert(iscellstr(detector.getClassNames()));

            img = imread(TestDPMDetector.im);
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

function download_cascade_model(fname)
    if exist(fname, 'file') ~= 2
        [~, f, ext] = fileparts(fname);
        assert(strcmpi(ext, '.xml'), 'Not an XML cascade model');
        % attempt to download cascade model from GitHub
        url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.2.0/testdata/cv/dpm/VOC2007_Cascade/';
        urlwrite([url f ext], fname);
    end
end
