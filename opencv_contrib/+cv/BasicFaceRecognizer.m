classdef BasicFaceRecognizer < handle
    %BASICFACERECOGNIZER  Face Recognition based on Eigen-/Fisher-faces
    %
    % All face recognition models in OpenCV are derived from the abstract base
    % class `FaceRecognizer`, which provides a unified access to all face
    % recongition algorithms in OpenCV.
    %
    % ### Description
    %
    % Every `FaceRecognizer` supports the:
    %
    % * __Training__ of a face recognizer with `train` on a given set of
    %   images (your face database!).
    % * __Prediction__ of a given sample image, that means a face. The image
    %   is given as a matrix.
    % * __Loading/Saving__ the model state from/to a given XML or YAML.
    % * __Setting/Getting labels info__, that is stored as a string. String
    %   labels info is useful for keeping names of the recognized people.
    %
    % ### Setting the Thresholds
    %
    % Sometimes you run into the situation, when you want to apply a threshold
    % on the prediction. A common scenario in face recognition is to tell,
    % whether a face belongs to the training dataset or if it is unknown.
    % You can set the thresholds in the constructor. You can also get/set the
    % thresholds at runtime!
    %
    % Here is an example of setting a threshold for the Eigenfaces method,
    % when creating the model:
    %
    %     % Let's say we want to keep 10 Eigenfaces and have a threshold value of 10.0
    %     num_components = 10;
    %     threshold = 10.0;
    %     % Then if you want to have a face recognizer with a confidence threshold,
    %     % create the concrete implementation with the appropiate parameters:
    %     model = cv.BasicFaceRecognizer('Eigenfaces', ...
    %         'NumComponents',num_components, 'Threshold',threshold);
    %
    % Sometimes it's impossible to train the model, just to experiment with
    % threshold values. It's possible to set model thresholds during runtime.
    % Let's see how we would set/get the prediction for the Eigenface model,
    % we've created above:
    %
    %     % The following line reads the threshold from the Eigenfaces model:
    %     current_threshold = model.Threshold;
    %     % And this line sets the threshold to 0.0:
    %     model.Threshold = 0.0;
    %
    % If you've set the threshold to 0.0 as we did above, then:
    %
    %     img = cv.imread('person1/3.jpg', 'Grayscale',true);
    %     % Get a prediction from the model. Note: We've set a threshold of 0.0 above,
    %     % since the distance is almost always larger than 0.0, you'll get -1 as
    %     % label, which indicates, this face is unknown
    %     predicted_label = model.predict(img);
    %     % ...
    %
    % is going to yield -1 as predicted label, which states this face is
    % unknown.
    %
    % ## References
    % [TP91]:
    % > Turk, M., and Pentland, A. "Eigenfaces for recognition".
    % > Journal of Cognitive Neuroscience 3 (1991), 71-86.
    %
    % [BHK97]:
    % > Belhumeur, P. N., Hespanha, J., and Kriegman, D. "Eigenfaces vs.
    % > Fisherfaces: Recognition using class specific linear projection".
    % > IEEE Transactions on Pattern Analysis and Machine Intelligence 19,
    % > 7 (1997), 711-720.
    %
    % See also: cv.LBPHFaceRecognizer, cv.PCA, cv.LDA
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The number of components kept by the PCA/LDA transformations.
        NumComponents
        % Threshold parameter, required for default BestMinDist collector.
        Threshold
    end

    %% Constructor/destructor
    methods
        function this = BasicFaceRecognizer(ftype, varargin)
            %BASICFACERECOGNIZER  Constructor
            %
            %     obj = cv.BasicFaceRecognizer(ftype)
            %     obj = cv.BasicFaceRecognizer(ftype, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __ftype__ Face recognizer type. One of:
            %   * __Eigenfaces__ Face Recognizer based on Eigenfaces.
            %   * __Fisherfaces__ Face Recognizer based on Fisherfaces.
            %
            % ## Options
            % * __NumComponents__ The number of components, default 0.
            %   * __Eigenfaces__ The number of components kept for this
            %     Principal Component Analysis. As a hint: There's no rule how
            %     many components (read: Eigenfaces) should be kept for good
            %     reconstruction capabilities. It is based on your input data,
            %     so experiment with the number. Keeping 80 components should
            %     almost always be sufficient.
            %   * __Fisherfaces__ The number of components kept for this
            %     Linear Discriminant Analysis with the Fisherfaces criterion.
            %     It's useful to keep all components, that means the number of
            %     your classes `c` (read: subjects, persons you want to
            %     recognize). If you leave this at the default (0) or set it
            %     to a value less-equal 0 or greater (`c-1`), it will be set
            %     to the correct number (`c-1`) automatically.
            % * __Threshold__ The threshold applied in the prediction. If the
            %   distance to the nearest neighbor is larger than the threshold,
            %   the prediction returns -1. default `realmax`
            %
            % ### Notes
            % - Training and prediction must be done on grayscale images, use
            %   cv.cvtColor to convert between the color spaces.
            % - THE EIGENFACES/FISHERFACES METHOD MAKES THE ASSUMPTION, THAT
            %   THE TRAINING AND TEST IMAGES ARE OF EQUAL SIZE. (caps-lock,
            %   because I got so many mails asking for this). You have to make
            %   sure your input data has the correct shape, else a meaningful
            %   exception is thrown. Use cv.resize to resize the images.
            % - This model does not support updating.
            %
            % See also: cv.BasicFaceRecognizer.train
            %
            this.id = BasicFaceRecognizer_(0, 'new', ftype, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.BasicFaceRecognizer
            %
            if isempty(this.id), return; end
            BasicFaceRecognizer_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = BasicFaceRecognizer_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BasicFaceRecognizer.empty,
            %  cv.BasicFaceRecognizer.load
            %
            BasicFaceRecognizer_(this.id, 'clear');
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
            % See also: cv.BasicFaceRecognizer.clear,
            %  cv.BasicFaceRecognizer.load
            %
            b = BasicFaceRecognizer_(this.id, 'empty');
        end

        function varargout = save(this, filename)
            %SAVE  Saves a FaceRecognizer and its model state
            %
            %     obj.save(filename)
            %     str = obj.save(filename)
            %
            % ## Input
            % * __filename__ The filename to store this FaceRecognizer to
            %   (either XML/YAML).
            %
            % ## Output
            % * __str__ optional output. If requested, the model is persisted
            %   to a string in memory instead of writing to disk.
            %
            % Saves this model to a given filename, either as XML or YAML.
            %
            % Saves the state of a model to the given filename.
            %
            % See also: cv.BasicFaceRecognizer.load
            %
            [varargout{1:nargout}] = BasicFaceRecognizer_(this.id, 'write', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads a FaceRecognizer and its model state
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %
            % ## Input
            % * __fname__ The filename to load this FaceRecognizer from
            %   (either XML/YAML).
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
            % See also: cv.BasicFaceRecognizer.save
            %
            BasicFaceRecognizer_(this.id, 'read', fname_or_str, varargin{:});
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
            % See also: cv.BasicFaceRecognizer.save,
            %  cv.BasicFaceRecognizer.load
            %
            name = BasicFaceRecognizer_(this.id, 'getDefaultName');
        end
    end

    %% FaceRecognizer
    methods
        function train(this, src, labels)
            %TRAIN  Trains a FaceRecognizer with given data and associated labels
            %
            %     obj.train(src, labels)
            %
            % ## Input
            % * __src__ The training images, that means the faces you want to
            %   learn. The data has to be given as a cell array of matrices.
            % * __labels__ The labels corresponding to the images. have to be
            %   given as an integer vector.
            %
            % The following source code snippet shows you how to learn a
            % Fisherfaces model on a given set of images. The images are read
            % with cv.imread and pushed into a cell array. The labels of each
            % image are stored within an integer vector. Think of the label as
            % the subject (the person) this image belongs to, so same subjects
            % (persons) should have the same label. For the available
            % FaceRecognizer you don't have to pay any attention to the order
            % of the labels, just make sure same persons have the same label:
            %
            %     % holds images and labels
            %     images = {};
            %     labels = [];
            %     % images for first person
            %     images{end+1} = cv.imread('person0/0.jpg', 'Grayscale',true);
            %     labels{end+1} = 0;
            %     images{end+1} = cv.imread('person0/1.jpg', 'Grayscale',true);
            %     labels{end+1} = 0;
            %     images{end+1} = cv.imread('person0/2.jpg', 'Grayscale',true);
            %     labels{end+1} = 0;
            %     % images for second person
            %     images{end+1} = cv.imread('person1/0.jpg', 'Grayscale',true);
            %     labels{end+1} = 1;
            %     images{end+1} = cv.imread('person1/1.jpg', 'Grayscale',true);
            %     labels{end+1} = 1;
            %     images{end+1} = cv.imread('person1/2.jpg', 'Grayscale',true);
            %     labels{end+1} = 1;
            %
            % Now that you have read some images, we can create a new
            % FaceRecognizer. In this example I'll create a Fisherfaces model
            % and decide to keep all of the possible Fisherfaces:
            %
            %     % Create a new Fisherfaces model and retain all available
            %     % Fisherfaces, this is the most common usage of this specific
            %     % FaceRecognizer:
            %     model = cv.BasicFaceRecognizer('Fisherfaces');
            %
            % And finally train it on the given dataset (the face images and
            % labels):
            %
            %     % This is the common interface to train all of the available FaceRecognizer
            %     % implementations:
            %     model.train(images, labels);
            %
            % See also: cv.BasicFaceRecognizer.predict
            %
            BasicFaceRecognizer_(this.id, 'train', src, labels);
        end

        function update(this, src, labels)
            %UPDATE  Updates a FaceRecognizer with given data and associated labels
            %
            %     obj.update(src, labels)
            %
            % ## Input
            % * __src__ The training images, that means the faces you want to
            %   learn. The data has to be given as a cell array of matrices.
            % * __labels__ The labels corresponding to the images. have to be
            %   given as an integer vector.
            %
            % This method updates a (probably trained) FaceRecognizer, but
            % only if the algorithm supports it. The Local Binary Patterns
            % Histograms (LBPH) recognizer (see cv.LBPHFaceRecognizer) can be
            % updated. For the Eigenfaces and Fisherfaces method, this is
            % algorithmically not possible and you have to re-estimate the
            % model with cv.BasicFaceRecognizer.train. In any case, a call to
            % train empties the existing model and learns a new model, while
            % update does not delete any model data.
            %
            %     % Create a new LBPH model (it can be updated) and use the
            %     % default parameters, this is the most common usage of this
            %     % specific FaceRecognizer:
            %     model = cv.LBPHFaceRecognizer();
            %     % This is the common interface to train all of the available
            %     % FaceRecognizer implementations:
            %     model.train(images, labels);
            %     % Some containers to hold new image.
            %     % You should add some images to the containers:
            %     newImages = {..};
            %     newLabels = [..];
            %     % Now updating the model is as easy as calling:
            %     model.update(newImages,newLabels);
            %     % This will preserve the old model data and extend the
            %     % existing model with the new features extracted from
            %     % newImages!
            %
            % Calling update on an Eigenfaces model (see
            % cv.BasicFaceRecognizer), which doesn't support updating, will
            % throw an error similar to:
            %
            %     OpenCV Error: The function/feature is not implemented (This
            %     FaceRecognizer (FaceRecognizer.Eigenfaces) does not support
            %     updating, you have to use FaceRecognizer::train to update it.)
            %
            % NOTE: The FaceRecognizer does not store your training images,
            % because this would be very memory intense and it's not the
            % responsibility of te FaceRecognizer to do so. The caller is
            % responsible for maintaining the dataset, he want to work with.
            %
            % See also: cv.BasicFaceRecognizer.train
            %
            BasicFaceRecognizer_(this.id, 'update', src, labels);
        end

        function [label, confidence] = predict(this, src)
            %PREDICT  Predicts a label and associated confidence (e.g. distance) for a given input image
            %
            %     [label, confidence] = obj.predict(src)
            %
            % ## Input
            % * __src__ Sample image to get a prediction from.
            %
            % ## Output
            % * __label__ The predicted label for the given image.
            % * __confidence__ Associated confidence (e.g. distance) for the
            %   predicted label.
            %
            % The following example shows how to get a prediction from a
            % trained model:
            %
            %     % Do your initialization here (create the FaceRecognizer model) ...
            %     % Read in a sample image:
            %     img = cv.imread('person1/3.jpg', 'Grayscale',true);
            %     % And get a prediction from the FaceRecognizer:
            %     predicted = model.predict(img);
            %
            % Or to get a prediction and the associated confidence (e.g.
            % distance):
            %
            %     % Do your initialization here (create the FaceRecognizer model) ...
            %     img = cv.imread('person1/3.jpg', 'Grayscale',true);
            %     % Get the prediction and associated confidence from the model
            %     [predicted_label, predicted_confidence] = model.predict(img);
            %
            % See also: cv.BasicFaceRecognizer.train
            %
            [label, confidence] = BasicFaceRecognizer_(this.id, 'predict', src);
        end

        function results = predict_collect(this, src, varargin)
            %PREDICT_COLLECT  send all result of prediction to collector for custom result handling
            %
            %     results = obj.predict_collect(src)
            %     results = obj.predict_collect(src, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ Sample image to get a prediction from.
            %
            % ## Output
            % * __results__ A struct array of all collected predictions labels
            %   and associated prediction distances for the given image.
            %
            % ## Options
            % * __Sorted__ If set, results will be sorted by distance. Each
            %   value is a pair of label and distance. default false
            %
            % See also: cv.BasicFaceRecognizer.predict
            %
            results = BasicFaceRecognizer_(this.id, 'predict_collect', src, varargin{:});
        end

        function setLabelInfo(this, label, strInfo)
            %SETLABELINFO  Sets string info for the specified model's label
            %
            %     obj.setLabelInfo(label, strInfo)
            %
            % ## Input
            % * __label__ label id.
            % * __strInfo__ string information.
            %
            % The string info is replaced by the provided value if it was set
            % before for the specified label.
            %
            % See also: cv.BasicFaceRecognizer.getLabelInfo
            %
            BasicFaceRecognizer_(this.id, 'setLabelInfo', label, strInfo);
        end

        function strInfo = getLabelInfo(this, label)
            %GETLABELINFO  Gets string information by label
            %
            %     strInfo = obj.getLabelInfo(label)
            %
            % ## Input
            % * __label__ label id.
            %
            % ## Output
            % * __strInfo__ string information associated with label.
            %
            % If an unknown label id is provided or there is no label
            % information associated with the specified label id the method
            % returns an empty string.
            %
            % See also: cv.BasicFaceRecognizer.setLabelInfo
            %
            strInfo = BasicFaceRecognizer_(this.id, 'getLabelInfo', label);
        end

        function labels = getLabelsByString(this, str)
            %GETLABELSBYSTRING  Gets vector of labels by string
            %
            %     labels = obj.getLabelsByString(str)
            %
            % ## Input
            % * __str__ string information (substring matching).
            %
            % ## Output
            % * __labels__ vector of labels.
            %
            % The function searches for the labels containing the specified
            % sub-string in the associated string info.
            %
            % See also: cv.BasicFaceRecognizer.getLabelInfo
            %
            labels = BasicFaceRecognizer_(this.id, 'getLabelsByString', str);
        end
    end

    %% BasicFaceRecognizer
    methods
        function projections = getProjections(this)
            %GETPROJECTIONS  Get training data projections
            %
            %     projections = obj.getProjections()
            %
            % ## Output
            % * __projections__ The projections of the training data. A cell
            %   array of length `N` (training set size), each cell contains a
            %   `double` vector of length `obj.NumComponents`.
            %
            % Note: returns an empty mat if the model is not trained.
            %
            % See also: cv.BasicFaceRecognizer.getLabels
            %
            projections = BasicFaceRecognizer_(this.id, 'getProjections');
        end

        function labels = getLabels(this)
            %GETLABELS  Get labels
            %
            %     labels = obj.getLabels()
            %
            % ## Output
            % * __labels__ The labels corresponding to the projections. An
            %   integer vector of length `N` (training set size).
            %
            % Note: returns an empty mat if the model is not trained.
            %
            % See also: cv.BasicFaceRecognizer.getProjections
            %
            labels = BasicFaceRecognizer_(this.id, 'getLabels');
        end

        function eigenvalues = getEigenValues(this)
            %GETEIGENVALUES  Get PCA/LDA eigenvalues
            %
            %     eigenvalues = obj.getEigenValues()
            %
            % ## Output
            % * __eigenvalues__ The eigenvalues for this Principal Component
            %   Analysis or Linear Discriminant Analysis (ordered descending).
            %   A `double` vector of length `obj.NumComponents`.
            %
            % Note: returns an empty mat if the model is not trained.
            %
            % See also: cv.BasicFaceRecognizer.getEigenVectors
            %
            eigenvalues = BasicFaceRecognizer_(this.id, 'getEigenValues');
        end

        function eigenvectors = getEigenVectors(this)
            %GETEIGENVECTORS  Get PCA/LDA eigenvectors
            %
            %     eigenvectors = obj.getEigenVectors()
            %
            % ## Output
            % * __eigenvectors__ The eigenvectors for this Principal Component
            %   Analysis or Linear Discriminant Analysis (ordered by their
            %   eigenvalue). A `double` matrix of size
            %   `(w*h)-by-obj.NumComponents` (each column is a an eigenvector).
            %
            % Note: returns an empty mat if the model is not trained.
            %
            % See also: cv.BasicFaceRecognizer.getEigenValues
            %
            eigenvectors = BasicFaceRecognizer_(this.id, 'getEigenVectors');
        end

        function m = getMean(this)
            %GETMEAN  Get sample mean
            %
            %     m = obj.getMean()
            %
            % ## Output
            % * __m__ The sample mean calculated from the training data. A
            %   `double` vector of length `w*h` (width and height of a face
            %   image).
            %
            % Note: returns an empty mat if the model is not trained.
            %
            % See also: cv.BasicFaceRecognizer.getProjections
            %
            m = BasicFaceRecognizer_(this.id, 'getMean');
        end
    end

    %% Getters/Setters
    methods
        function value = get.NumComponents(this)
            value = BasicFaceRecognizer_(this.id, 'get', 'NumComponents');
        end
        function set.NumComponents(this, value)
            BasicFaceRecognizer_(this.id, 'set', 'NumComponents', value);
        end

        function value = get.Threshold(this)
            value = BasicFaceRecognizer_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            BasicFaceRecognizer_(this.id, 'set', 'Threshold', value);
        end
    end

end
