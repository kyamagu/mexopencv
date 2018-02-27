classdef FacemarkKazemi < handle
    %FACEMARKKAZEMI  Face Alignment
    %
    % An implementation of state of the art face alignment technique proposed
    % by [Kazemi2014].
    %
    % The paper demonstrates how an ensemble of regression trees can be used
    % to estimate the face's landmark positions directly from a sparse subset
    % of pixel intensities, achieving super-realtime performance with
    % high-quality predictions.
    %
    % ## Face Alignment
    % Face alignment is a computer vision technology for identifying the
    % geometric structure of human faces in digital images. Given the location
    % and size of a face, it automatically determines the shape of the face
    % components such as eyes, nose, and lips.
    %
    % A face alignment program typically operates by iteratively adjusting a
    % deformable models, which encodes the prior knowledge of face shape or
    % appearance, to take into account the low-level image evidences and find
    % the face that is present in the image.
    %
    % ## References
    % [Kazemi2014]:
    % > Vahid Kazemi and Josephine Sullivan, "One Millisecond Face Alignment
    % > with an Ensemble of Regression Trees", CVPR 2014.
    % > [PDF](https://www.cv-foundation.org/openaccess/content_cvpr_2014/papers/Kazemi_One_Millisecond_Face_2014_CVPR_paper.pdf)
    %
    % See also: cv.Facemark, cv.FacemarkKazemi.FacemarkKazemi
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
        function this = FacemarkKazemi(varargin)
            %FACEMARKKAZEMI  Constructor
            %
            %     obj = cv.FacemarkKazemi()
            %     obj = cv.FacemarkKazemi('OptionName',optionValue, ...)
            %
            % ## Options
            % * __CascadeDepth__ depth of cascade used for training.
            %   default 15
            % * __TreeDepth__ max height of the regression tree built.
            %   default 5
            % * __NumTreesPerCascadeLevel__ number of trees fit per cascade
            %   level. default 500
            % * __LearningRate__ learning rate in gradient boosting, also
            %   refered to as shrinkage. default 0.1
            % * __OversamplingAmount__ number of initializations used to
            %   create training samples. default 20
            % * __NumTestCoordinates__ number of test coordinates. default 500
            % * __Lambda__ value to calculate probability of closeness of two
            %   coordinates. default 0.1
            % * __NumTestSplits__ number of random test splits generated.
            %   default 20
            % * __ConfigFile__ name of the file containing the values of
            %   training parameters. default ''
            %
            % These variables are used for training data. They are initialised
            % as described in the referenced research paper.
            %
            % See also: cv.FacemarkKazemi.loadModel
            %
            this.func = '';
            this.id = FacemarkKazemi_(0, this.func, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.FacemarkKazemi
            %
            if isempty(this.id), return; end
            FacemarkKazemi_(this.id, this.func, 'delete');
        end
    end

    %% FacemarkKazemi
    methods
        function success = training(this, images, landmarks, configFile, scale, varargin)
            %TRAINING  Trains a facemark model
            %
            %     success = obj.training(images, landmarks, configFile, scale)
            %     success = obj.training(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __images__ cell-array of images which are used in training
            %   samples.
            % * __landmarks__ cell-array of cell-array of points which stores
            %   the landmarks detected in a particular image.
            % * __configFile__ name of the file storing parameters for
            %   training the model. For an example, see the
            %   |facemark_kazemi_train_config_demo.m| sample.
            % * __scale__ size to which all images and landmarks have to be
            %   scaled to `[w,h]`.
            %
            % ## Output
            % * __success__ returns true if the model is trained properly or
            %   false if it is not trained.
            %
            % ## Options
            % * __ModelFilename__ name of the trained model file that has to
            %   be saved. default 'face_landmarks.dat'
            %
            % Trains a facemark model using gradient boosting to get a cascade
            % of regressors which can then be used to predict shape.
            %
            % See also: cv.FacemarkKazemi.loadModel
            %
            success = FacemarkKazemi_(this.id, this.func, 'training', images, landmarks, configFile, scale, varargin{:});
        end

        function loadModel(this, filename)
            %LOADMODEL  Load the trained model
            %
            %     obj.loadModel(filename)
            %
            % ## Input
            % * __filename__ A string which stores the name of the file in
            %   which trained model is stored.
            %
            % See also: cv.FacemarkKazemi.fit
            %
            FacemarkKazemi_(this.id, this.func, 'loadModel', filename);
        end

        function [landmarks, success] = fit(this, img, faces, varargin)
            %FIT  Retrieves a centered and scaled face shape, according to the bounding rectangle
            %
            %     [landmarks, success] = obj.fit(img, faces)
            %     [...] = obj.fit(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image whose landmarks have to be found.
            % * __faces__ Cell-array of bounding boxes of faces found in a
            %   given image `{[x,y,w,h], ...}`.
            %
            % ## Output
            % * __landmarks__ Cell-array of cell-array of points which stores
            %   the landmarks of all the faces found in the image
            %   `{{[x,y], ...}, ...}`.
            % * __success__ success flag.
            %
            % See also: cv.FacemarkKazemi.loadModel
            %
            [landmarks, success] = FacemarkKazemi_(this.id, this.func, 'fit', img, faces, varargin{:});
        end

        function success = setFaceDetector(this, detector)
            %SETFACEDETECTOR  Set the custom face detector
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
            % See also: cv.FacemarkKazemi.getFaces
            %
            this.func = detector;
            success = FacemarkKazemi_(this.id, this.func, 'setFaceDetector', detector);
        end

        function [faces, success] = getFaces(this, img)
            %GETFACES  Detect faces using the custom detector
            %
            %     [faces, success] = obj.getFaces(img)
            %
            % ## Input
            % * __img__ Input image.
            %
            % ## Output
            % * __faces__ Detected faces `{[x,y,w,h], ...}`. Each face is
            %   stored as rect.
            % * __success__ success flag.
            %
            % See also: cv.FacemarkKazemi.setFaceDetector
            %
            [faces, success] = FacemarkKazemi_(this.id, this.func, 'getFaces', img);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.FacemarkKazemi.empty, cv.FacemarkKazemi.load
            %
            FacemarkKazemi_(this.id, this.func, 'clear');
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
            % See also: cv.FacemarkKazemi.clear, cv.FacemarkKazemi.load
            %
            b = FacemarkKazemi_(this.id, this.func, 'empty');
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
            % See also: cv.FacemarkKazemi.load
            %
            [varargout{1:nargout}] = FacemarkKazemi_(this.id, this.func, 'write', filename);
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
            % See also: cv.FacemarkKazemi.save
            %
            FacemarkKazemi_(this.id, this.func, 'read', fname_or_str, varargin{:});
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
            % See also: cv.FacemarkKazemi.save, cv.FacemarkKazemi.load
            %
            name = FacemarkKazemi_(this.id, this.func, 'getDefaultName');
        end
    end

end
