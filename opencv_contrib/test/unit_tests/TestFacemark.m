classdef TestFacemark
    %TestFacemark

    properties (Constant)
        func = 'myFaceDetector';
        root = fullfile(mexopencv.root(),'test','facemark');
        fCascade = fullfile(mexopencv.root(),'test','lbpcascade_frontalface.xml');
    end

    methods (Static)
        function test_create
            obj = cv.Facemark('LBF');
            assert(isobject(obj));

            obj = cv.Facemark('AAM');
            assert(isobject(obj));
        end

        function test_haar_detect
            img = cv.imread(fullfile(TestFacemark.root,'david1.jpg'));
            download_classifier_xml(TestFacemark.fCascade);
            [faces, b] = cv.Facemark.getFacesHAAR(img, TestFacemark.fCascade);
            validateattributes(faces, {'cell'}, {'vector'});
            cellfun(@(f) validateattributes(f, {'numeric'}, ...
                {'vector', 'numel',4}), faces);
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_default_detector
            img = cv.imread(fullfile(TestFacemark.root,'david1.jpg'));
            download_classifier_xml(TestFacemark.fCascade);
            obj = cv.Facemark('LBF', 'CascadeFace',TestFacemark.fCascade);
            [faces, b] = obj.getFaces(img);
            validateattributes(faces, {'cell'}, {'vector'});
            cellfun(@(f) validateattributes(f, {'numeric'}, ...
                {'vector', 'numel',4}), faces);
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_custom_detector
            % skip test if external M-file is not found on the path
            if ~exist([TestFacemark.func '.m'], 'file')
                error('mexopencv:testskip', 'undefined function');
            end

            if true
                obj = cv.Facemark('LBF');
            else
                obj = cv.Facemark('AAM');
            end

            b = obj.setFaceDetector(TestFacemark.func);
            validateattributes(b, {'logical'}, {'scalar'});

            img = cv.imread(fullfile(TestFacemark.root,'david1.jpg'));
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

            modelFilename = fullfile(tempdir(), 'model.yaml');
            opts = {'Verbose',false, ...
                'ModelFilename',modelFilename, 'SaveModel',true};
            if true
                download_classifier_xml(TestFacemark.fCascade);
                obj = cv.Facemark('LBF', ...
                    'CascadeFace',TestFacemark.fCascade, opts{:});
            else
                obj = cv.Facemark('AAM', 'N',1, 'M',1, opts{:});
            end

            fImgs = cv.glob(fullfile(TestFacemark.root,'david*.jpg'));
            fPts = cv.glob(fullfile(TestFacemark.root,'david*.pts'));
            for i=1:numel(fImgs)
                [pts, b] = cv.Facemark.loadFacePoints(fPts{i});
                validateattributes(pts, {'cell'}, {'vector'});
                cellfun(@(p) validateattributes(p, {'numeric'}, ...
                    {'vector', 'numel',2}), pts);
                validateattributes(b, {'logical'}, {'scalar'});

                img = cv.imread(fImgs{i});
                b = obj.addTrainingSample(img, pts);
                validateattributes(b, {'logical'}, {'scalar'});
            end
            obj.training();
            assert(exist(modelFilename, 'file') == 2, 'no trained model saved');
            delete(modelFilename);
        end

        function test_detect
            download_classifier_xml(TestFacemark.fCascade);
            obj = cv.Facemark('LBF', 'CascadeFace',TestFacemark.fCascade);
            obj.loadModel(get_model_file());

            img = cv.imread(fullfile(TestFacemark.root,'david1.jpg'));

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

            if ~isempty(pts)
                out = cv.Facemark.drawFacemarks(img, pts{1}, 'Color',[255 0 0]);
                validateattributes(out, {class(img)}, {'size',size(img)});
            end
        end

        function test_load_dataset_list
            %TODO: these text files contain hardcoded paths
            if true
                error('mexopencv:testskip', 'todo');
            end
            [imgFiles, ptsFiles, b] = cv.Facemark.loadDatasetList(...
                fullfile(TestFacemark.root,'images.txt'), ...
                fullfile(TestFacemark.root,'annotations.txt'));
            validateattributes(imgFiles, {'cell'}, {'vector'});
            assert(iscellstr(imgFiles));
            validateattributes(ptsFiles, {'cell'}, ...
                {'vector', 'numel',numel(imgFiles)});
            assert(iscellstr(ptsFiles));
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_load_data_1
            %TODO: these text files contain hardcoded paths
            if true
                error('mexopencv:testskip', 'todo');
            end
            [imgFiles, pts, b] = cv.Facemark.loadTrainingData1(...
                fullfile(TestFacemark.root,'images.txt'), ...
                fullfile(TestFacemark.root,'annotations.txt'));
            validateattributes(imgFiles, {'cell'}, {'vector'});
            assert(iscellstr(imgFiles));
            validateattributes(pts, {'cell'}, ...
                {'vector', 'numel',numel(imgFiles)});
            cellfun(@(c) validateattributes(c, {'cell'}, {'vector'}), pts);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), c), pts);
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_load_data_2
            %TODO: these text files contain hardcoded paths
            if true
                error('mexopencv:testskip', 'todo');
            end
            [imgFiles, pts, b] = cv.Facemark.loadTrainingData2(...
                fullfile(TestFacemark.root,'points.txt'));
            validateattributes(imgFiles, {'cell'}, {'vector'});
            assert(iscellstr(imgFiles));
            validateattributes(pts, {'cell'}, ...
                {'vector', 'numel',numel(imgFiles)});
            cellfun(@(c) validateattributes(c, {'cell'}, {'vector'}), pts);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), c), pts);
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_load_data_3
            %TODO: these text files contain hardcoded paths
            if true
                error('mexopencv:testskip', 'todo');
            end
            fPoints = cv.glob(fullfile(TestFacemark.root,'david*.txt'));
            [imgFiles, pts, b] = cv.Facemark.loadTrainingData3(fPoints);
            validateattributes(imgFiles, {'cell'}, ...
                {'vector', 'numel',numel(fPoints)});
            assert(iscellstr(imgFiles));
            validateattributes(pts, {'cell'}, ...
                {'vector', 'numel',numel(imgFiles)});
            cellfun(@(c) validateattributes(c, {'cell'}, {'vector'}), pts);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), c), pts);
            validateattributes(b, {'logical'}, {'scalar'});
        end
    end

end

function modelFile = get_model_file()
    modelFile = fullfile(mexopencv.root(),'test','lbfmodel.yaml');
    if exist(modelFile, 'file') ~= 2
        % download model from GitHub (~ 54MB)
        url = 'https://github.com/kurnianggoro/GSOC2017/raw/master/data/lbfmodel.yaml';
        urlwrite(url, modelFile);
    end
end

function download_classifier_xml(fname)
    if exist(fname, 'file') ~= 2
        % attempt to download trained Haar/LBP/HOG classifier from Github
        url = 'https://cdn.rawgit.com/opencv/opencv/3.4.0/data/';
        [~, f, ext] = fileparts(fname);
        if strncmpi(f, 'haarcascade_', length('haarcascade_'))
            url = [url, 'haarcascades/'];
        elseif strncmpi(f, 'lbpcascade_', length('lbpcascade_'))
            url = [url, 'lbpcascades/'];
        elseif strncmpi(f, 'hogcascade_', length('hogcascade_'))
            url = [url, 'hogcascades/'];
        else
            error('File not found');
        end
        urlwrite([url f ext], fname);
    end
end

% TODO: this function needs to be on the path as a top-level function
%       saved in its own M-file.

function faces = myFaceDetector(img)
    persistent obj
    if isempty(obj)
        obj = cv.CascadeClassifier();
        obj.load(TestFacemark.fCascade);
    end

    if size(img,3) > 1
        gray = cv.cvtColor(img, 'RGB2GRAY');
    else
        gray = img;
    end
    gray = cv.equalizeHist(gray);
    faces = obj.detect(gray, 'ScaleFactor',1.4, 'MinNeighbors',2, ...
        'ScaleImage',true, 'MinSize',[30 30]);
end
