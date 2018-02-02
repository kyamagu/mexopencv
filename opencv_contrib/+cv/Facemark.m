classdef Facemark < handle
    %FACEMARK  Base class for all facemark models
    %
    % Facial landmark detection is a useful algorithm with many possible
    % applications including expression transfer, virtual make-up, and facial
    % puppetry. This class implements an API for facial landmark detector.
    % Two kinds of algorithms are implemented including active appearance
    % model [AAM] and regressed local binary features [LBF] able to work in
    % real-time.
    %
    % All facemark models in OpenCV are derived from the abstract base class
    % Facemark, which provides a unified access to all facemark algorithms in
    % OpenCV.
    %
    % To utilize the Facemark API in your program, please take a look at the
    % opencv tutorials, as well as mexopencv samples.
    %
    % ## Description
    % Facemark is a base class which provides universal access to any specific
    % facemark algorithm. Therefore, the users should declare a desired
    % algorithm before they can use it in their application.
    %
    % The typical pipeline for facemark detection is listed as follows:
    %
    % - (Non-mandatory) Set a user defined face detection using
    %   cv.Facemark.setFaceDetector. The facemark algorithms are desgined
    %   to fit the facial points into a face. Therefore, the face information
    %   should be provided to the facemark algorithm. Some algorithms might
    %   provides a default face recognition function. However, the users might
    %   prefer to use their own face detector to obtains the best possible
    %   detection result.
    % - (Non-mandatory) Training the model for a specific algorithm using
    %   cv.Facemark.training. In this case, the model should be
    %   automatically saved by the algorithm. If the user already have a
    %   trained model, then this part can be omitted.
    % - Load the trained model using cv.Facemark.loadModel.
    % - Perform the fitting via the cv.Facemark.fit.
    %
    % ### Example
    % Here is an example of loading a pretrained model
    % (you should provide full paths to files specified below):
    %
    %     obj = cv.Facemark('LBF', 'CascadeFace','lbpcascade_frontalface.xml');
    %     obj.loadModel('lbfmodel.yaml');
    %     img = imread('lena.jpg');
    %     faces = obj.getFaces(img);
    %     landmarks = obj.fit(img, faces);
    %     for i=1:numel(faces)
    %         img = cv.rectangle(img, faces{i}, 'Color','g');
    %         img = cv.Facemark.drawFacemarks(img, landmarks{i});
    %     end
    %     imshow(img)
    %
    % ### Example
    % Here is an example of training a model:
    %
    %     % filename to save the trained model
    %     obj = cv.Facemark('LBF', 'ModelFilename','ibug68.model');
    %     obj.setFaceDetector('myFaceDetector');
    %
    %     % load the list of dataset: image paths and landmark file paths
    %     [imgFiles, ptsFiles] = cv.Facemark.loadDatasetList(...
    %         'data/images_train.txt', 'data/points_train.txt');
    %
    %     % add training samples
    %     for i=1:numel(imgFiles)
    %         img = imread(imgFiles{i});
    %         pts = cv.Facemark.loadFacePoints(ptsFiles{i});
    %         obj.addTrainingSample(img, pts);
    %     end
    %     obj.training();
    %
    % ## References
    % [AAM]:
    % > G. Tzimiropoulos and M. Pantic, "Optimization problems for fast AAM
    % > fitting in-the-wild," ICCV 2013.
    %
    % [LBF]:
    % > S. Ren, et al. , "Face alignment at 3000 fps via regressing local
    % > binary features", CVPR 2014.
    %
    % See also: cv.FacemarkKazemi, cv.Facemark.Facemark
    %

    properties (SetAccess = private)
        % Object ID
        id
        % name of custom face detector function
        % (due to an implementation detail,
        % we must maintain its state and keep passing it on each call)
        func
    end

    %% Constructor/destructor
    methods
        function this = Facemark(ftype, varargin)
            %FACEMARK  Constructor
            %
            %     obj = cv.Facemark(ftype)
            %     obj = cv.Facemark(ftype, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __ftype__ Facemark algorithm, one of:
            %   * __LBF__ regressed local binary features (LBF).
            %   * __AAM__ active appearance model (AAM).
            %
            % ## Options for LBF
            % * __ShapeOffset__ offset for the loaded face landmark points.
            %   default 0.0
            % * __CascadeFace__ filename of the face detector model. default ''
            % * __Verbose__ show the training print-out. default true
            % * __NLandmarks__ number of landmark points. default 68
            % * __InitShapeN__ multiplier for augment the training data.
            %   default 10
            % * __StagesN__ number of refinement stages. default 5
            % * __TreeN__ number of tree in the model for each landmark point
            %   refinement. default 6
            % * __TreeDepth__ the depth of decision tree, defines the size of
            %   feature. default 5
            % * __BaggingOverlap__ overlap ratio for training the LBF feature.
            %   default 0.4
            % * __ModelFilename__ filename where the trained model will be
            %   saved (Base64 encoded). default ''
            % * __SaveModel__ flag to save the trained model or not.
            %   default true
            % * __Seed__ seed for shuffling the training data. default 0
            % * __FeatsM__ default `[500,500,500,300,300,300,200,200,200,100]`
            % * __RadiusM__
            %   default `[0.3,0.2,0.15,0.12,0.10,0.10,0.08,0.06,0.06,0.05]`
            % * __Pupils__ index of facemark points on pupils of left and
            %   right eye. default `{[36,37,38,39,40,41], [42,43,44,45,46,47]}`
            % * __DetectROI__ default `[-1,-1,-1,-1]`
            %
            % ## Options for AAM
            % * __ModelFilename__ filename where the trained model will be
            %   saved (Base64 encoded). default ''
            % * __SaveModel__ flag to save the trained model or not.
            %   default true
            % * __M__ default 200
            % * __N__ default 10
            % * __NIter__ default 50
            % * __Verbose__ show the training print-out. default true
            % * __MaxM__ default 550
            % * __MaxN__ default 136
            % * __TextureMaxM__ default 145
            % * __Scales__ the scales considered to build the model.
            %   default `[1.0,]`
            %
            % See also: cv.Facemark.loadModel
            %
            this.func = '';
            this.id = Facemark_(0, this.func, 'new', ftype, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Facemark
            %
            if isempty(this.id), return; end
            Facemark_(this.id, this.func, 'delete');
        end
    end

    %% Facemark
    methods
        function success = addTrainingSample(this, img, landmarks)
            %ADDTRAININGSAMPLE  Add one training sample to the trainer
            %
            %     success = obj.addTrainingSample(img, landmarks)
            %
            % ## Input
            % * __img__ Input image.
            % * __landmarks__ The ground-truth of facial landmarks points
            %   corresponds to the image `{[x,y], ...}`.
            %
            % ## Output
            % * __success__ success flag.
            %
            % In the case of LBF, this function internally calls the face
            % detector function, so you will need to either pass the option
            % `CascadeFace` to use the default detector, or set a custom
            % function in cv.Facemark.setFaceDetector
            %
            % See also: cv.Facemark.training
            %
            success = Facemark_(this.id, this.func, 'addTrainingSample', img, landmarks);
        end

        function training(this)
            %TRAINING  Trains a Facemark algorithm using the given dataset
            %
            %     obj.training()
            %
            % Before the training process, training samples should be added to
            % the trainer using cv.Facemark.addTrainingSample function.
            %
            % See also: cv.Facemark.addTrainingSample
            %
            Facemark_(this.id, this.func, 'training');
        end

        function loadModel(this, model)
            %LOADMODEL  A function to load the trained model before the fitting process
            %
            %     obj.loadModel(model)
            %
            % ## Input
            % * __model__ A string represent the filename of a trained model.
            %
            % See also: cv.Facemark.fit
            %
            Facemark_(this.id, this.func, 'loadModel', model);
        end

        function [landmarks, success] = fit(this, img, faces, varargin)
            %FIT  Detect landmarks in faces
            %
            %     [landmarks, success] = obj.fit(img, faces)
            %     [...] = obj.fit(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image.
            % * __faces__ Detected faces `{[x,y,w,h], ...}`.
            %
            % ## Output
            % * __landmarks__ The detected landmark points for each face
            %   `{{[x,y], ...}, ...}`.
            % * __success__ success flag.
            %
            % ## Options for AAM
            % * __Configs__ Optional runtime parameter for fitting process,
            %   only supported for AAM algorithm. A struct-array of the same
            %   length as `faces` with the following fields:
            %   * __R__ 2x2 rotation matrix. default `eye(2,'single')`
            %   * __t__ 2-elements translation vector.
            %     default `[size(img,2) size(img,1)] / 2`
            %   * __scale__ scaling factor. default 1.0
            %   * __scaleIdx__ 0-based model scale index (into `Scales` vector
            %     from the constructor options). default 0
            %
            % See also: cv.Facemark.loadModel
            %
            [landmarks, success] = Facemark_(this.id, this.func, 'fit', img, faces, varargin{:});
        end

        function success = setFaceDetector(this, detector)
            %SETFACEDETECTOR  Set a user-defined face detector for the Facemark algorithm
            %
            %     success = obj.setFaceDetector(detector)
            %
            % ## Input
            % * __detector__ The user-defined face detector, MATLAB function
            %   name.
            %
            % ## Output
            % * __success__ success flag.
            %
            % The user-defined face detector should have the following
            % signature:
            %
            %     function faces = myFaceDetector(img)
            %
            % where `img` is the input image and `faces` is the output with
            % the detected faces.
            %
            % Note that some algorithms might provide a default face detector
            % (LBF does, but AAM does not).
            %
            % See also: cv.Facemark.getFaces
            %
            this.func = detector;
            success = Facemark_(this.id, this.func, 'setFaceDetector', detector);
        end

        function [faces, success] = getFaces(this, img)
            %GETFACES  Detect faces from a given image using default or user-defined face detector
            %
            %     [faces, success] = obj.getFaces(img)
            %
            % ## Input
            % * __img__ Input image.
            %
            % ## Output
            % * __faces__ Output of the function which represent region of
            %   interest of the detected faces `{[x,y,w,h], ...}`. Each face
            %   is stored as rect.
            % * __success__ success flag.
            %
            % See also: cv.Facemark.setFaceDetector
            %
            [faces, success] = Facemark_(this.id, this.func, 'getFaces', img);
        end

        function [items, success] = getData(this)
            %GETDATA  Get data from an algorithm
            %
            %     [items, success] = obj.getData()
            %
            % ## Output
            % * __items__ The obtained data, algorithm dependent.
            % * __success__ success flag.
            %
            % Only for AAM algorithm, not used in LBF (returns empty data).
            %
            % See also: cv.Facemark.setFaceDetector
            %
            [items, success] = Facemark_(this.id, this.func, 'getData');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.Facemark.empty, cv.Facemark.load
            %
            Facemark_(this.id, this.func, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.Facemark.clear, cv.Facemark.load
            %
            b = Facemark_(this.id, this.func, 'empty');
        end

        function varargout = save(this, filename)
            %SAVE  Saves a Facemark and its model state
            %
            %     obj.save(filename)
            %     str = obj.save(filename)
            %
            % ## Input
            % * __filename__ The filename to store this Facemark to (XML/YAML).
            %
            % ## Output
            % * __str__ optional output. If requested, the model is persisted
            %   to a string in memory instead of writing to disk.
            %
            % Saves this model to a given filename, either as XML or YAML.
            %
            % Saves the state of a model to the given filename.
            %
            % See also: cv.Facemark.load
            %
            [varargout{1:nargout}] = Facemark_(this.id, this.func, 'write', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads a Facemark and its model state
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %
            % ## Input
            % * __fname__ The filename to load this Facemark from (XML/YAML).
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % Loads a persisted model and state from a given XML or YAML file.
            %
            % See also: cv.Facemark.save
            %
            Facemark_(this.id, this.func, 'read', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.Facemark.save, cv.Facemark.load
            %
            name = Facemark_(this.id, this.func, 'getDefaultName');
        end
    end

    %% Static methods
    methods (Static)
        function [faces, success] = getFacesHAAR(img, faceCascadeName)
            %GETFACESHAAR  Default face detector
            %
            %     [faces, success] = cv.Facemark.getFacesHAAR(img, faceCascadeName)
            %
            % ## Input
            % * __img__ The input image to be processed.
            % * __faceCascadeName__ Name of the XML file from which a trained
            %   cascade classifier is loaded. See cv.CascadeClassifier.load
            %
            % ## Output
            % * __faces__ Output of the function which represent region of
            %   interest of the detected faces `{[x,y,w,h], ...}`. Each face
            %   is stored as rect.
            % * __success__ success flag.
            %
            % This function is mainly utilized by the implementation of a
            % Facemark algorithm. End users are advised to use function
            % cv.Facemark.getFaces which can be manually defined and
            % circumvented to the algorithm by cv.Facemark.setFaceDetector.
            %
            % ### Example
            %
            %     faces = cv.Facemark.getFacesHAAR(img, 'haarcascade_frontalface_alt.xml');
            %     for i=1:numel(faces)
            %         img = cv.rectangle(img, faces{i}, 'Color',[0 255 0]);
            %     end
            %     imshow(img)
            %
            % See also: cv.Facemark.setFaceDetector, cv.CascadeClassifier
            %
            [faces, success] = Facemark_(0, '', 'getFacesHAAR', img, faceCascadeName);
        end

        function [imagesPaths, annotationsPaths, success] = loadDatasetList(imagesList, annotationsList)
            %LOADDATASETLIST  A utility to load list of paths to training images and annotation files
            %
            %     [imagesPaths, annotationsPaths, success] = cv.Facemark.loadDatasetList(imagesList, annotationsList)
            %
            % ## Input
            % * __imagesList__ The specified file contains paths to the
            %   training images.
            % * __annotationsList__ The specified file contains paths to the
            %   training annotations.
            %
            % ## Output
            % * __imagesPaths__ The loaded paths of training images.
            % * __annotationsPaths__ The loaded paths of annotation files.
            % * __success__ success flag.
            %
            % This format is utilized in most facial point annotation datasets
            % (IBUG, HELEN, LPWF, etc.). There are two kinds of files provided
            % in the dataset, images and their corresponding facial point data.
            % The user provides the list of image files and annotations in two
            % separate files. These files can be generated easily using `dir`
            % or `ls` commands from the terminal.
            %
            % The contents of the list files follow a standard format with one
            % path per line.
            %
            % Example contents of images list file:
            %
            %     /path/to/image1.jpg
            %     /path/to/image2.jpg
            %     ...
            %
            % and contents of corresponding landmarks list file:
            %
            %     /path/to/image1.pts
            %     /path/to/image2.pts
            %     ...
            %
            % where the format of |.pts| files is described in
            % cv.Facemark.loadFacePoints function.
            %
            % See also: cv.Facemark.loadFacePoints,
            %  cv.Facemark.loadTrainingData1
            %
            [imagesPaths, annotationsPaths, success] = Facemark_(0, '', 'loadDatasetList', imagesList, annotationsList);
        end

        function [imagesPaths, landmarks, success] = loadTrainingData1(imagesList, annotationsList, varargin)
            %LOADTRAININGDATA1  A utility to load facial landmark information from the dataset
            %
            %     [imagesPaths, landmarks, success] = cv.Facemark.loadTrainingData1(imagesList, annotationsList)
            %     [...] = cv.Facemark.loadTrainingData1(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __imagesList__ A file contains the list of image filenames in
            %   the training dataset.
            % * __annotationsList__ A file contains the list of filenames where
            %   the ground-truth landmarks points information are stored. The
            %   content in each file should follow the standard format (see
            %   cv.Facemark.loadFacePoints).
            %
            % ## Output
            % * __imagesPaths__ A cell-aray where each element represent the
            %   filename of image in the dataset. Images are not loaded by
            %   default to save memory.
            % * __landmarks__ The loaded landmark points for all training
            %   data `{{[x,y], ...}, ...}`.
            % * __success__ success flag.
            %
            % ## Options
            % * __Offset__ An offset value to adjust the loaded points.
            %   default 0.0
            %
            % The same dataset format described in cv.Facemark.loadDatasetList
            % function. However this function directly loads the annotation
            % data instead of only returning their file paths.
            %
            % See also: cv.Facemark.loadDatasetList
            %
            [imagesPaths, landmarks, success] = Facemark_(0, '', 'loadTrainingData1', imagesList, annotationsList, varargin{:});
        end

        function [imagesPaths, landmarks, success] = loadTrainingData2(filename, varargin)
            %LOADTRAININGDATA2  A utility to load facial landmark dataset from a single file
            %
            %     [imagesPaths, landmarks, success] = cv.Facemark.loadTrainingData2(filename)
            %     [...] = cv.Facemark.loadTrainingData2(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ The filename of a file that contains the dataset
            %   information. Each line contains the filename of an image
            %   followed by pairs of `x` and `y` values of facial landmarks
            %   points separated by a space.
            %
            % ## Output
            % * __imagesPaths__ A cell-aray where each element represent the
            %   filename of image in the dataset. Images are not loaded by
            %   default to save memory.
            % * __landmarks__ The loaded landmark points for all training
            %   data `{{[x,y], ...}, ...}`.
            % * __success__ success flag.
            %
            % ## Options
            % * __Delim__ Delimiter between each element, the default value is
            %   a whitespace `' '`.
            % * __Offset__ An offset value to adjust the loaded points.
            %   default 0.0
            %
            % This dataset format simply consists of a single file, where each
            % line contains an image path followed by list of x/y coordinates
            % of its corresponding annotation. Number of points of each sample
            % is not included, and the code will load all value pairs until
            % the end of line.
            %
            % Example of file format expected:
            %
            %     /path/to/image1.jpg 336.820955 240.864510 334.238298 260.922709 ...
            %     /path/to/image2.jpg 376.158428 230.845712 376.736984 254.924635 ...
            %     ...
            %
            % See also: cv.Facemark.loadTrainingData3
            %
            [imagesPaths, landmarks, success] = Facemark_(0, '', 'loadTrainingData2', filename, varargin{:});
        end

        function [imagesPaths, landmarks, success] = loadTrainingData3(filenames)
            %LOADTRAININGDATA3  Extracts the data for training from .txt files which contains the corresponding image name and landmarks
            %
            %     [imagesPaths, landmarks, success] = cv.Facemark.loadTrainingData3(filenames)
            %
            % ## Input
            % * __filenames__ A cell-array of strings containing names of the
            %   text files.
            %
            % ## Output
            % * __imagesPaths__ A cell-array of strings which stores the
            %   filenames of images whose landmarks are tracked.
            % * __landmarks__ A cell-array of cell-array of points that would
            %   store shape or landmarks of all images `{{[x,y],...}, ...}`.
            % * __success__ success flag. It returns true when it reads the
            %   data successfully and false otherwise.
            %
            % An alternative dataset format. Similar to the one described in
            % cv.Facemark.loadTrainingData2, but with separate files for each
            % sample.
            %
            % The training data consists of |.txt| files whose first line
            % contains the image name, followed by the annotations. Example:
            %
            %  /path/to/image1.jpg
            %  565.86 , 758.98
            %  564.27 , 781.14
            %  ...
            %
            % See also: cv.Facemark.loadTrainingData2
            %
            [landmarks, imagesPaths, success] = Facemark_(0, '', 'loadTrainingData3', filenames);
        end

        function [points, success] = loadFacePoints(filename)
            %LOADFACEPOINTS  A utility to load facial landmark information from a given file
            %
            %     [points, success] = cv.Facemark.loadFacePoints(filename)
            %
            % ## Input
            % * __filename__ The filename of `.pts` file which contains the
            %   facial landmarks data.
            %
            % ## Output
            % * __points__ The loaded facial landmark points `{[x,y], ...}`.
            % * __success__ success flag.
            %
            % ## Options
            % * __Offset__ An offset value to adjust the loaded points.
            %   default 0.0
            %
            % The annotation file should follow the default format which is:
            %
            %     version: 1
            %     n_points:  68
            %     {
            %     212.716603 499.771793
            %     230.232816 566.290071
            %     ...
            %     }
            %
            % where `n_points` is the number of points considered and each
            % point is represented as its position in `x` and `y`.
            %
            % See also: cv.Facemark.loadDatasetList,
            %  cv.Facemark.loadTrainingData1
            %
            [points, success] = Facemark_(0, '', 'loadFacePoints', filename);
        end

        function img = drawFacemarks(img, points, varargin)
            %DRAWFACEMARKS  Utility to draw the detected facial landmark points
            %
            %     img = cv.Facemark.drawFacemarks(img, points)
            %     img = cv.Facemark.drawFacemarks(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ The input image to be processed.
            % * __points__ Contains the data of points which will be drawn
            %   `{[x,y], ...}`.
            %
            % ## Output
            % * __img__ Output image with drawn points.
            %
            % ## Options
            % * __Color__ The color of points represented in BGR format,
            %   default `[255,0,0]`.
            %
            % See also: cv.circle, cv.Facemark.fit
            %
            img = Facemark_(0, '', 'drawFacemarks', img, points, varargin{:});
        end
    end

end
