classdef LBPHFaceRecognizer < handle
    %LBPHFACERECOGNIZER  Face Recognition based on Local Binary Patterns
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
    % [AHP06]:
    % > Ahonen T., Hadid A. and Pietikainen M. "Face description with local
    % > binary patterns: Application to face recognition." IEEE Transactions
    % > on Pattern Analysis and Machine Intelligence, 28(12):2037-2041.
    %
    % See also: cv.BasicFaceRecognizer, extractLBPFeatures
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The number of cells in the horizontal direction.
        GridX
        % The number of cells in the vertical direction.
        GridY
        % The radius used for building the Circular LBP.
        Radius
        % The number of sample points to build a Circular LBP from.
        Neighbors
        % Threshold parameter, required for default BestMinDist collector.
        Threshold
    end

    %% Constructor/destructor
    methods
        function this = LBPHFaceRecognizer(varargin)
            %LBPHFACERECOGNIZER  Constructor
            %
            %     obj = cv.LBPHFaceRecognizer('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Radius__ The radius used for building the Circular Local
            %   Binary Pattern. The greater the radius, the smoother the image
            %   but more spatial information you can get. default 1
            % * __Neighbors__ The number of sample points to build a Circular
            %   Local Binary Pattern from. An appropriate value is to use 8
            %   sample points. Keep in mind: the more sample points you
            %   include, the higher the computational cost. default 8
            % * __GridX__ The number of cells in the horizontal direction, 8
            %   is a common value used in publications. The more cells, the
            %   finer the grid, the higher the dimensionality of the resulting
            %   feature vector. default 8
            % * __GridY__ The number of cells in the vertical direction, 8 is
            %   a common value used in publications. The more cells, the finer
            %   the grid, the higher the dimensionality of the resulting
            %   feature vector. default 8
            % * __Threshold__ The threshold applied in the prediction. If the
            %   distance to the nearest neighbor is larger than the threshold,
            %   the prediction returns -1. default `realmax`
            %
            % Initializes this LBPH Model. The current implementation is
            % rather fixed as it uses the Extended Local Binary Patterns per
            % default.
            %
            % `Radius` and `Neighbors` are used in the local binary patterns
            % creation. `GridX` and `GridY` control the grid size of the
            % spatial histograms.
            %
            % ### Notes
            % - The Circular Local Binary Patterns (used in training and
            %   prediction) expect the data given as grayscale images, use
            %   cv.cvtColor to convert between the color spaces.
            % - This model supports updating.
            %
            % See also: cv.LBPHFaceRecognizer.train
            %
            this.id = LBPHFaceRecognizer_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.LBPHFaceRecognizer
            %
            if isempty(this.id), return; end
            LBPHFaceRecognizer_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = LBPHFaceRecognizer_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.LBPHFaceRecognizer.empty, cv.LBPHFaceRecognizer.load
            %
            LBPHFaceRecognizer_(this.id, 'clear');
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
            % See also: cv.LBPHFaceRecognizer.clear, cv.LBPHFaceRecognizer.load
            %
            b = LBPHFaceRecognizer_(this.id, 'empty');
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
            % See also: cv.LBPHFaceRecognizer.load
            %
            [varargout{1:nargout}] = LBPHFaceRecognizer_(this.id, 'write', filename);
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
            % See also: cv.LBPHFaceRecognizer.save
            %
            LBPHFaceRecognizer_(this.id, 'read', fname_or_str, varargin{:});
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
            % See also: cv.LBPHFaceRecognizer.save, cv.LBPHFaceRecognizer.load
            %
            name = LBPHFaceRecognizer_(this.id, 'getDefaultName');
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
            % See also: cv.LBPHFaceRecognizer.predict
            %
            LBPHFaceRecognizer_(this.id, 'train', src, labels);
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
            % See also: cv.LBPHFaceRecognizer.train
            %
            LBPHFaceRecognizer_(this.id, 'update', src, labels);
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
            % See also: cv.LBPHFaceRecognizer.train
            %
            [label, confidence] = LBPHFaceRecognizer_(this.id, 'predict', src);
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
            % See also: cv.LBPHFaceRecognizer.predict
            %
            results = LBPHFaceRecognizer_(this.id, 'predict_collect', src, varargin{:});
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
            % See also: cv.LBPHFaceRecognizer.getLabelInfo
            %
            LBPHFaceRecognizer_(this.id, 'setLabelInfo', label, strInfo);
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
            % See also: cv.LBPHFaceRecognizer.setLabelInfo
            %
            strInfo = LBPHFaceRecognizer_(this.id, 'getLabelInfo', label);
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
            % See also: cv.LBPHFaceRecognizer.getLabelInfo
            %
            labels = LBPHFaceRecognizer_(this.id, 'getLabelsByString', str);
        end
    end

    %% LBPHFaceRecognizer
    methods
        function hists = getHistograms(this)
            %GETHISTOGRAMS  Get calculated LBP histograms
            %
            %     hists = obj.getHistograms()
            %
            % ## Output
            % * __hists__ Local Binary Patterns Histograms calculated from the
            %   given training data (empty if none was given). A cell array of
            %   length `N` (training set size), each cell contains a `single`
            %   vector of length `B` representing the number of features (it
            %   depends on the image and grid sizes and number of neighbors).
            %
            % See also: cv.LBPHFaceRecognizer.getLabels
            %
            hists = LBPHFaceRecognizer_(this.id, 'getHistograms');
        end

        function labels = getLabels(this)
            %GETLABELS  Get labels
            %
            %     labels = obj.getLabels()
            %
            % ## Output
            % * __labels__ Labels corresponding to the calculated Local Binary
            %   Patterns Histograms. An integer vector of length `N` (training
            %   set size).
            %
            % Note: returns an empty mat if the model is not trained.
            %
            % See also: cv.LBPHFaceRecognizer.getHistograms
            %
            labels = LBPHFaceRecognizer_(this.id, 'getLabels');
        end
    end

    %% Getters/Setters
    methods
        function value = get.GridX(this)
            value = LBPHFaceRecognizer_(this.id, 'get', 'GridX');
        end
        function set.GridX(this, value)
            LBPHFaceRecognizer_(this.id, 'set', 'GridX', value);
        end

        function value = get.GridY(this)
            value = LBPHFaceRecognizer_(this.id, 'get', 'GridY');
        end
        function set.GridY(this, value)
            LBPHFaceRecognizer_(this.id, 'set', 'GridY', value);
        end

        function value = get.Radius(this)
            value = LBPHFaceRecognizer_(this.id, 'get', 'Radius');
        end
        function set.Radius(this, value)
            LBPHFaceRecognizer_(this.id, 'set', 'Radius', value);
        end

        function value = get.Neighbors(this)
            value = LBPHFaceRecognizer_(this.id, 'get', 'Neighbors');
        end
        function set.Neighbors(this, value)
            LBPHFaceRecognizer_(this.id, 'set', 'Neighbors', value);
        end

        function value = get.Threshold(this)
            value = LBPHFaceRecognizer_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            LBPHFaceRecognizer_(this.id, 'set', 'Threshold', value);
        end
    end

end
