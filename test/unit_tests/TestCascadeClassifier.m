classdef TestCascadeClassifier
    %TestCascadeClassifier
    properties (Constant)
        xmlfile = fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt2.xml');
    end

    methods (Static)
        function test_old_format
            im = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            cc = cv.CascadeClassifier(TestCascadeClassifier.xmlfile);
            rects = cc.detect(im);
            if ~isempty(rects)
                validateattributes(rects, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer'}), rects);
            end
        end

        function test_new_format
            %xmlfile = fullfile(mexopencv.root(),'test','lbpcascade_frontalface.xml');
            xmlfile = fullfile(mexopencv.root(),'test','haarcascade_frontalface_default.xml');
            download_classifier_xml(xmlfile);

            cc = cv.CascadeClassifier();
            assert(cc.empty());
            cc.load(xmlfile);
            assert(~cc.empty());
            validateattributes(cc.isOldFormatCascade(), {'logical'}, {'scalar'});
            validateattributes(cc.getOriginalWindowSize(), {'numeric'}, {'vector', 'numel',2});
            assert(strcmp(cc.getFeatureType(), 'Haar'));

            im = imread(fullfile(mexopencv.root(),'test','tsukuba.png'));
            [rects, num] = cc.detect(im, 'ScaleFactor',1.1, 'MinNeighbors',3);
            if ~isempty(rects)
                validateattributes(rects, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer'}), rects);
                validateattributes(num, {'numeric'}, ...
                    {'vector', 'numel',numel(rects), 'integer'});
            end
        end

        function test_convet_formats
            filename = [tempname '.xml'];
            cObj = onCleanup(@() deleteFile(filename));

            b = cv.CascadeClassifier.convert(TestCascadeClassifier.xmlfile, filename);
            validateattributes(b, {'logical'}, {'scalar'});
            assert(b);

            cc = cv.CascadeClassifier(filename);
            assert(~cc.empty() && ~cc.isOldFormatCascade());
        end

        function test_mask_generator
            % skip test if external M-file is not found on the path
            if ~exist('my_mask_generator.m', 'file')
                disp('SKIP')
                return;
            end
            xmlfile = fullfile(mexopencv.root(),'test','haarcascade_frontalface_default.xml');
            download_classifier_xml(xmlfile);
            cc = cv.CascadeClassifier(xmlfile);
            assert(~cc.isOldFormatCascade());
            cc.setMaskGenerator('my_mask_generator');
            S = cc.getMaskGenerator();
            validateattributes(S, {'struct'}, {'scalar'});
            assert(isfield(S, 'fun') && strcmp(S.fun, 'my_mask_generator'));

            im = imread(fullfile(mexopencv.root(),'test','tsukuba.png'));
            rects = cc.detect(im);
        end

        function test_face_mask_generator
            xmlfile = fullfile(mexopencv.root(),'test','haarcascade_frontalface_default.xml');
            download_classifier_xml(xmlfile);
            cc = cv.CascadeClassifier(xmlfile);
            assert(~cc.isOldFormatCascade());
            cc.setMaskGenerator('FaceDetectionMaskGenerator');  %TODO
            S = cc.getMaskGenerator();
            validateattributes(S, {'struct'}, {'scalar'});

            im = imread(fullfile(mexopencv.root(),'test','tsukuba.png'));
            rects = cc.detect(im);
        end
    end

end

function deleteFile(fname)
    if exist(fname, 'file') == 2
        delete(fname);
    end
end

function download_classifier_xml(fname)
    if ~exist(fname, 'file')
        % attempt to download trained Haar/LBP/HOG classifier from Github
        url = 'https://cdn.rawgit.com/Itseez/opencv/3.0.0/data/';
        [~, f, ext] = fileparts(fname);
        if strncmpi(f, 'haarcascade_', length('haarcascade_'))
            url = fullfile(url, 'haarcascades');
        elseif strncmpi(f, 'lbpcascade_', length('lbpcascade_'))
            url = fullfile(url, 'lbpcascades');
        elseif strncmpi(f, 'hogcascade_', length('hogcascade_'))
            url = fullfile(url, 'hogcascades');
        else
            error('File not found');
        end
        disp('Downloading cascade classifier...')
        urlwrite(strrep(fullfile(url,[f ext]),'\','/'), fname);
    end
end

% TODO: this needs to be on the path as a top-level function in its own M-file
function mask = my_mask_generator(gray)
    % restrict search to the bottom half of the image only
    mask = ones(size(gray), 'uint8') * 255;
    mask(1:end/2,:) = 0;
end
