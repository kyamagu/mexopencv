classdef TestFacemarkKazemi
    %TestFacemarkKazemi

    properties (Constant)
        func = 'myFaceDetector';
        root = fullfile(mexopencv.root(),'test','facemark');
    end

    methods (Static)
        function test_create
            obj = cv.FacemarkKazemi();
            assert(isobject(obj));
        end

        function test_custom_detector
            % skip test if external M-file is not found on the path
            if ~exist([TestFacemarkKazemi.func '.m'], 'file')
                error('mexopencv:testskip', 'undefined function');
            end

            obj = cv.FacemarkKazemi();
            b = obj.setFaceDetector(TestFacemarkKazemi.func);
            validateattributes(b, {'logical'}, {'scalar'});

            img = cv.imread(fullfile(TestFacemarkKazemi.root,'david1.jpg'));
            [faces, b] = obj.getFaces(img);
            validateattributes(faces, {'cell'}, {'vector'});
            cellfun(@(f) validateattributes(f, {'numeric'}, ...
                {'vector', 'numel',4}), faces);
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_train
            if true
                % training is time consuming
                error('mexopencv:testskip', 'slow');
            end

            % skip test if external M-file is not found on the path
            if ~exist([TestFacemark.func '.m'], 'file')
                error('mexopencv:testskip', 'undefined function');
            end

            modelFilename = fullfile(tempdir(),'model.dat');
            fConfig = fullfile(TestFacemarkKazemi.root,'config.xml');
            fImgs = cv.glob(fullfile(TestFacemarkKazemi.root,'david*.jpg'));
            fPts = cv.glob(fullfile(TestFacemarkKazemi.root,'david*.pts'));

            obj = cv.FacemarkKazemi('ConfigFile',fConfig);
            obj.setFaceDetector(TestFacemarkKazemi.func);

            imgs = cellfun(@cv.imread, fImgs, 'UniformOutput',false);
            pts = cellfun(@cv.Facemark.loadFacePoints, fPts, 'UniformOutput',false);

            b = obj.training(imgs, pts, fConfig, [460 460], ...
                'ModelFilename',modelFilename);
            validateattributes(b, {'logical'}, {'scalar'});
            assert(exist(modelFilename, 'file') == 2, 'no trained model saved');
            delete(modelFilename);
        end

        function test_detect
            % skip test if external M-file is not found on the path
            if ~exist([TestFacemark.func '.m'], 'file')
                error('mexopencv:testskip', 'undefined function');
            end

            obj = cv.FacemarkKazemi();
            obj.setFaceDetector(TestFacemarkKazemi.func);
            obj.loadModel(get_model_file());

            img = cv.imread(fullfile(TestFacemarkKazemi.root,'david1.jpg'));

            [faces, b] = obj.getFaces(img);
            validateattributes(faces, {'cell'}, {'vector'});
            cellfun(@(f) validateattributes(f, {'numeric'}, ...
                {'vector', 'numel',4}), faces);
            validateattributes(b, {'logical'}, {'scalar'});

            [pts, b] = obj.fit(img, faces);
            validateattributes(pts, {'cell'}, {'vector', 'numel',numel(faces)});
            cellfun(@(c) validateattributes(c, {'cell'}, {'vector'}), pts);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), c), pts);
            validateattributes(b, {'logical'}, {'scalar'});
        end
    end

end

function modelFile = get_model_file()
    modelFile = fullfile(mexopencv.root(),'test','face_landmark_model.dat');
    if exist(modelFile, 'file') ~= 2
        % download model from GitHub (~ 69MB)
        url = 'https://cdn.rawgit.com/opencv/opencv_3rdparty/contrib_face_alignment_20170818/face_landmark_model.dat';
        urlwrite(url, modelFile);
    end
end

% TODO: this function needs to be on the path as a top-level function
%       saved in its own M-file.

function faces = myFaceDetector(img)
    persistent obj
    if isempty(obj)
        obj = cv.CascadeClassifier();
        xmlfile = fullfile(mexopencv.root(),'test','lbpcascade_frontalface.xml');
        assert(exist(xmlfile, 'file') == 2, 'missing cascade classifier file');
        obj.load(xmlfile);
    end

    if size(img,3) > 1
        gray = cv.cvtColor(img, 'RGB2GRAY');
    else
        gray = img;
    end
    gray = cv.equalizeHist(gray);
    faces = obj.detect(gray, 'ScaleFactor',1.1, 'MinNeighbors',3, ...
        'ScaleImage',false, 'MinSize',[30 30]);
end
