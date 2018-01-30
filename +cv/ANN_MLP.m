classdef ANN_MLP < handle
    %ANN_MLP  Artificial Neural Networks - Multi-Layer Perceptrons
    %
    % Unlike many other models in ML that are constructed and trained at once,
    % in the MLP model these steps are separated. First, a network with the
    % specified topology is created. All the weights are set to zeros. Then,
    % the network is trained using a set of input and output vectors. The
    % training procedure can be repeated more than once, that is, the weights
    % can be adjusted based on the new training data.
    %
    % ## Neural Networks
    %
    % ML implements feed-forward artificial neural networks or, more
    % particularly, multi-layer perceptrons (MLP), the most commonly used type
    % of neural networks. MLP consists of the input layer, output layer, and
    % one or more hidden layers. Each layer of MLP includes one or more
    % neurons directionally linked with the neurons from the previous and the
    % next layer. The example below represents a 3-layer perceptron with three
    % inputs, two outputs, and the hidden layer including five neurons:
    %
    % ![image](https://docs.opencv.org/3.3.1/mlp.png)
    %
    % All the neurons in MLP are similar. Each of them has several input links
    % (it takes the output values from several neurons in the previous layer
    % as input) and several output links (it passes the response to several
    % neurons in the next layer). The values retrieved from the previous layer
    % are summed up with certain weights, individual for each neuron, plus the
    % bias  term. The sum is transformed using the activation function `f`
    % that may be also different for different neurons.
    %
    % ![image](https://docs.opencv.org/3.3.1/neuron_model.png)
    %
    % In other words, given the outputs `x_j` of the layer `n`, the outputs
    % `y_i` of the layer `n+1` are computed as:
    %
    %     u_i = sum_j (w_{i,j}^{n+1} * x_j) + w_{i,bias}^{n+1}
    %     y_i = f(u_i)
    %
    % Different activation functions may be used. ML implements three standard
    % functions:
    %
    % * __Identity__: Identity function `f(x) = y`
    % * __Sigmoid__: Symmetrical sigmoid, which is the default choice for MLP
    %   `f(x) = beta * (1-exp(-alpha*x)) / (1+exp(-alpha*x))`
    % * __Gaussian__: Gaussian function, which is not completely supported at
    %   the moment `f(x) = beta * exp(-alpha*x*x)`
    %
    % ![image](https://docs.opencv.org/3.3.1/sigmoid_bipolar.png)
    %
    % In ML, all the neurons have the same activation functions, with the
    % same free parameters (`alpha`, `beta`) that are specified by user and
    % are not altered by the training algorithms.
    %
    % So, the whole trained network works as follows:
    %
    % 1. Take the feature vector as input. The vector size is equal to the
    %    size of the input layer.
    % 2. Pass values as input to the first hidden layer.
    % 3. Compute outputs of the hidden layer using the weights and the
    %    activation functions.
    % 4. Pass outputs further downstream until you compute the output layer.
    %
    % So, to compute the network, you need to know all the weights
    % `w_{i,j}^{n+1}`. The weights are computed by the training algorithm. The
    % algorithm takes a training set, multiple input vectors with the
    % corresponding output vectors, and iteratively adjusts the weights to
    % enable the network to give the desired response to the provided input
    % vectors.
    %
    % The larger the network size (the number of hidden layers and their
    % sizes) is, the more the potential network flexibility is. The error on
    % the training set could be made arbitrarily small. But at the same time
    % the learned network also learn the noise present in the training set, so
    % the error on the test set usually starts increasing after the network
    % size reaches a limit. Besides, the larger networks are trained much
    % longer than the smaller ones, so it is reasonable to pre-process the
    % data, using cv.PCA or similar technique, and train a smaller network on
    % only essential features.
    %
    % Another MPL feature is an inability to handle categorical data as is.
    % However, there is a workaround. If a certain feature in the input or
    % output (in case of n-class classifier for `n>2`) layer is categorical
    % and can take `M>2` different values, it makes sense to represent it as a
    % binary tuple of `M` elements, where the i-th element is 1 if and only if
    % the feature is equal to the i-th value out of `M` possible. It increases
    % the size of the input/output layer but speeds up the training algorithm
    % convergence and at the same time enables fuzzy values of such variables,
    % that is, a tuple of probabilities instead of a fixed value.
    %
    % ML implements two algorithms for training MLP's.The first algorithm
    % is a classical random sequential back-propagation algorithm. The second
    % (default) one is a batch RPROP algorithm.
    %
    % ## References
    % [BackPropWikipedia]:
    % > [Back-propagation algorithm](https://en.wikipedia.org/wiki/Backpropagation)
    %
    % [LeCun98]:
    % > LeCun, L. Bottou, G.B. Orr and K.-R. Muller, "Efficient backprop",
    % > in Neural Networks Tricks of the Trade, Springer Lecture Notes in
    % > Computer Sciences 1524, pp.5-50, 1998.
    %
    % [RPROP93]:
    % > M. Riedmiller and H. Braun, "A Direct Adaptive Method for Faster
    % > Backpropagation Learning: The RPROP Algorithm", Proc. ICNN, San
    % > Francisco (1993).
    %
    % See also: cv.ANN_MLP.ANN_MLP, cv.ANN_MLP.train, cv.ANN_MLP.predict,
    %  nnstart, nprtool, nftool
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Training method of the MLP.
        %
        % Default 'RProp'. Possible values are:
        %
        % * __Backprop__ The back-propagation algorithm.
        % * __RProp__ (default) The RPROP algorithm. See [RPROP93] for details.
        % * __Anneal__ The simulated annealing algorithm. See [Kirkpatrick83]
        %   for details.
        %
        % See also: cv.ANN_MLP.setTrainMethod
        TrainMethod
        % Integer vector specifying the number of neurons in each layer
        % including the input and output layers of the MLP.
        %
        % The very first element specifies the number of elements in the input
        % layer (feature dimensions). The last element is the number of
        % elements in the output layer (regression dimensions). For example,
        % `[N,1]` means two-layer network that takes an N-dimensional vector
        % as an input and output scalar. default empty (which means it must be
        % manually set before training).
        LayerSizes
        % Termination criteria of the training algorithm.
        %
        % You can specify the maximum number of iterations (`maxCount`) and/or
        % how much the error could change between the iterations to make the
        % algorithm continue (`epsilon`). Default value is
        % `struct('type','Count+EPS', 'maxCount',1000, 'epsilon',0.01)`.
        % A struct with the following fields is accepted:
        %
        % * __type__ one of {'Count', 'EPS', 'Count+EPS'}
        % * __maxCount__ maximum number of iterations
        % * __epsilon__ error tolerance value
        TermCriteria
        % BPROP: Strength of the weight gradient term.
        %
        % The recommended value is about 0.1. Default value is 0.1.
        BackpropWeightScale
        % BPROP: Strength of the momentum term (the difference between weights
        % on the 2 previous iterations).
        %
        % This parameter provides some inertia to smooth the random
        % fluctuations of the weights. It can vary from 0 (the feature is
        % disabled) to 1 and beyond. The value 0.1 or so is  good enough.
        % Default value is 0.1.
        BackpropMomentumScale
        % RPROP: Initial value `delta_0` of update-values `delta_ij`.
        %
        % Default value is 0.1.
        RpropDW0
        % RPROP: Increase factor `eta_plus`.
        %
        % It must be >1. Default value is 1.2.
        RpropDWPlus
        % RPROP: Decrease factor `eta_minus`.
        %
        % It must be <1. Default value is 0.5.
        RpropDWMinus
        % RPROP: Update-values lower limit `delta_min`.
        %
        % It must be positive. Default value is `eps('single')`.
        RpropDWMin
        % RPROP: Update-values upper limit `delta_max`.
        %
        % It must be >1. Default value is 50.
        RpropDWMax
        % ANNEAL: initial temperature. It must be >= 0. Default value is 10.0.
        AnnealInitialT
        % ANNEAL: final temperature. It must be >= 0 and less than
        % `AnnealInitialT`. Default value is 0.1.
        AnnealFinalT
        % ANNEAL: cooling ratio. It must be > 0 and less than 1. Default value
        % is 0.95.
        AnnealCoolingRatio
        % ANNEAL: iteration per step. It must be > 0. Default value is 10.
        AnnealItePerStep
    end

    properties (Dependent, GetAccess = private)
        % Activation function for all neurons.
        %
        % Default 'Sigmoid' (with `alpha=0` and `beta=0`).
        %
        % See also: cv.ANN_MLP.setActivationFunction
        ActivationFunction
    end

    %% Constructor/destructor
    methods
        function this = ANN_MLP()
            %ANN_MLP  Creates an empty ANN-MLP model
            %
            %     model = cv.ANN_MLP()
            %
            % Use `train` to train the model, or `load` to load a pre-trained
            % model. Note that the train method has optional flags.
            %
            % See also: cv.ANN_MLP, cv.ANN_MLP.train, cv.ANN_MLP.load
            %
            this.id = ANN_MLP_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     model.delete()
            %
            % See also: cv.ANN_MLP
            %
            if isempty(this.id), return; end
            ANN_MLP_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     model.clear()
            %
            % The method clear does the same job as the destructor: it
            % deallocates all the memory occupied by the class members. But
            % the object itself is not destructed and can be reused further.
            % This method is called from the destructor, from the `train` and
            % `load` methods, or even explicitly by the user.
            %
            % See also: cv.ANN_MLP.empty, cv.ANN_MLP.load
            %
            ANN_MLP_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = model.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.ANN_MLP.clear, cv.ANN_MLP.load
            %
            b = ANN_MLP_(this.id, 'empty');
        end

        function varargout = save(this, filename)
            %SAVE  Saves the algorithm parameters to a file or a string
            %
            %     model.save(filename)
            %     str = model.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to. In case of string
            %   output, only the filename extension is used to determine the
            %   output format (XML or YAML).
            %
            % ## Output
            % * __str__ optional output. If requested, the model is persisted
            %   to a string in memory instead of writing to disk.
            %
            % This method stores the complete model state to the specified
            % XML or YAML file (or to a string in memory, based on the number
            % of output arguments).
            %
            % See also: cv.ANN_MLP.load
            %
            [varargout{1:nargout}] = ANN_MLP_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     model.load(filename)
            %     model.load(str, 'FromString',true)
            %     model.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model (switches
            %   between `Algorithm<T>::load()` and
            %   `Algorithm<T>::loadFromString()` C++ methods). default false
            %
            % This method loads the complete model state from the specified
            % XML or YAML file (either from disk or serialized string). The
            % previous model state is cleared.
            %
            % See also: cv.ANN_MLP.save
            %
            ANN_MLP_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = model.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.ANN_MLP.save, cv.ANN_MLP.load
            %
            name = ANN_MLP_(this.id, 'getDefaultName');
        end
    end

    %% StatModel
    methods
        function count = getVarCount(this)
            %GETVARCOUNT  Returns the number of variables in training samples
            %
            %     count = model.getVarCount()
            %
            % ## Output
            % * __count__ number of variables in training samples.
            %
            % See also: cv.ANN_MLP.train
            %
            count = ANN_MLP_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %     b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.ANN_MLP.empty, cv.ANN_MLP.train
            %
            b = ANN_MLP_(this.id, 'isTrained');
        end

        function b = isClassifier(this)
            %ISCLASSIFIER  Returns true if the model is a classifier
            %
            %     b = model.isClassifier()
            %
            % ## Output
            % * __b__ Returns true if the model is a classifier, false if the
            %   model is a regressor.
            %
            % Always false for ANN MLP models.
            %
            % See also: cv.ANN_MLP.isTrained
            %
            b = ANN_MLP_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains/updates the MLP
            %
            %     status = model.train(samples, responses)
            %     status = model.train(csvFilename, [])
            %     [...] = model.train(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ matrix of training samples. It should be
            %   floating-point type. By default, each row represents a sample
            %   (see the `Layout` option).
            % * __responses__ Floating-point matrix of the corresponding
            %   output vectors, one vector per row.
            % * __csvFilename__ The input CSV file name from which to load
            %   dataset. In this variant, you should set the second argument
            %   to an empty array.
            %
            % ## Output
            % * __status__ Success flag.
            %
            % ## Options
            % * __Data__ Training data options, specified as a cell array of
            %   key/value pairs of the form `{'key',val, ...}`. See below.
            % * __Flags__ The optional training flags, model-dependent. For
            %   convenience, you can set the individual flag options below,
            %   instead of directly setting bits here. default 0
            % * __UpdateWeights__ Algorithm updates the network weights,
            %   rather than computes them from scratch. In the latter case the
            %   weights are initialized using the Nguyen-Widrow algorithm.
            %   default false.
            % * __NoInputScale__ Algorithm does not normalize the input
            %   vectors. If this flag is not set, the training algorithm
            %   normalizes each input feature independently, shifting its mean
            %   value to 0 and making the standard deviation equal to 1. If
            %   the network is assumed to be updated frequently, the new
            %   training data could be much different from original one. In
            %   this case, you should take care of proper normalization.
            %   default false.
            % * __NoOutputScale__ Algorithm does not normalize the output
            %   vectors. If the flag is not set, the training algorithm
            %   normalizes each output feature independently, by transforming
            %   it to the certain range depending on the used activation
            %   function. default false.
            %
            % ### Options for `Data` (first variant with samples and reponses)
            % * __Layout__ Sample types. Default 'Row'. One of:
            %   * __Row__ each training sample is a row of samples.
            %   * __Col__ each training sample occupies a column of samples.
            % * __VarIdx__ vector specifying which variables to use for
            %   training. It can be an integer vector (`int32`) containing
            %   0-based variable indices or logical vector (`uint8` or
            %   `logical`) containing a mask of active variables. Not set by
            %   default, which uses all variables in the input data.
            % * __SampleIdx__ vector specifying which samples to use for
            %   training. It can be an integer vector (`int32`) containing
            %   0-based sample indices or logical vector (`uint8` or
            %   `logical`) containing a mask of training samples of interest.
            %   Not set by default, which uses all samples in the input data.
            % * __SampleWeights__ optional floating-point vector with weights
            %   for each sample. Some samples may be more important than
            %   others for training. You may want to raise the weight of
            %   certain classes to find the right balance between hit-rate and
            %   false-alarm rate, and so on. Not set by default, which
            %   effectively assigns an equal weight of 1 for all samples.
            % * __VarType__ optional vector of type `uint8` and size
            %   `<num_of_vars_in_samples> + <num_of_vars_in_responses>`,
            %   containing types of each input and output variable. By default
            %   considers all variables as numerical (both input and output
            %   variables). In case there is only one output variable of
            %   integer type, it is considered categorical. You can also
            %   specify a cell-array of strings (or as one string of single
            %   characters, e.g 'NNNC'). Possible values:
            %   * __Numerical__, __N__ same as 'Ordered'
            %   * __Ordered__, __O__ ordered variables
            %   * __Categorical__, __C__ categorical variables
            % * __MissingMask__ Indicator mask for missing observation (not
            %   currently implemented). Not set by default
            % * __TrainTestSplitCount__ divides the dataset into train/test
            %   sets, by specifying number of samples to use for the test set.
            %   By default all samples are used for the training set.
            % * __TrainTestSplitRatio__ divides the dataset into train/test
            %   sets, by specifying ratio of samples to use for the test set.
            %   By default all samples are used for the training set.
            % * __TrainTestSplitShuffle__ when splitting dataset into
            %   train/test sets, specify whether to shuffle the samples.
            %   Otherwise samples are assigned sequentially (first train then
            %   test). default true
            %
            % ### Options for `Data` (second variant for loading CSV file)
            % * __HeaderLineCount__ The number of lines in the beginning to
            %   skip; besides the header, the function also skips empty lines
            %   and lines staring with '#'. default 1
            % * __ResponseStartIdx__ Index of the first output variable. If
            %   -1, the function considers the last variable as the response.
            %   If the dataset only contains input variables and no responses,
            %   use `ResponseStartIdx = -2` and `ResponseEndIdx = 0`, then the
            %   output variables vector will just contain zeros. default -1
            % * __ResponseEndIdx__ Index of the last output variable + 1. If
            %   -1, then there is single response variable at
            %   `ResponseStartIdx`. default -1
            % * __VarTypeSpec__ The optional text string that specifies the
            %   variables' types. It has the format
            %   `ord[n1-n2,n3,n4-n5,...]cat[n6,n7-n8,...]`. That is, variables
            %   from `n1` to `n2` (inclusive range), `n3`, `n4` to `n5` ...
            %   are considered ordered and `n6`, `n7` to `n8` ... are
            %   considered as categorical. The range
            %   `[n1..n2] + [n3] + [n4..n5] + ... + [n6] + [n7..n8]` should
            %   cover all the variables. If `VarTypeSpec` is not specified,
            %   then algorithm uses the following rules:
            %   * all input variables are considered ordered by default. If
            %     some column contains has non- numerical values, e.g.
            %     'apple', 'pear', 'apple', 'apple', 'mango', the
            %     corresponding variable is considered categorical.
            %   * if there are several output variables, they are all
            %     considered as ordered. Errors are reported when
            %     non-numerical values are used.
            %   * if there is a single output variable, then if its values are
            %     non-numerical or are all integers, then it's considered
            %     categorical. Otherwise, it's considered ordered.
            % * __Delimiter__ The character used to separate values in each
            %   line. default ','
            % * __Missing__ The character used to specify missing
            %   measurements. It should not be a digit. Although it's a
            %   non-numerical value, it surely does not affect the decision of
            %   whether the variable ordered or categorical. default '?'
            % * __TrainTestSplitCount__ same as above.
            % * __TrainTestSplitRatio__ same as above.
            % * __TrainTestSplitShuffle__ same as above.
            %
            % This method applies the specified training algorithm to
            % computing/adjusting the network weights.
            %
            % The RPROP training algorithm is parallelized with the TBB
            % library.
            %
            % If you are using the default 'Sigmoid' activation function then
            % the output should be in the range [-1,1], instead of [0,1], for
            % optimal results.
            %
            % See also: cv.ANN_MLP.predict, cv.ANN_MLP.calcError
            %
            status = ANN_MLP_(this.id, 'train', samples, responses, varargin{:});
        end

        function [err,resp] = calcError(this, samples, responses, varargin)
            %CALCERROR  Computes error on the training or test dataset
            %
            %     err = model.calcError(samples, responses)
            %     err = model.calcError(csvFilename, [])
            %     [err,resp] = model.calcError(...)
            %     [...] = model.calcError(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ See the train method.
            % * __responses__ See the train method.
            % * __csvFilename__ See the train method.
            %
            % ## Output
            % * __err__ computed error.
            % * __resp__ the optional output responses.
            %
            % ## Options
            % * __Data__ See the train method.
            % * __TestError__ if true, the error is computed over the test
            %   subset of the data, otherwise it's computed over the training
            %   subset of the data. Please note that if you loaded a
            %   completely different dataset to evaluate an already trained
            %   classifier, you will probably want not to set the test subset
            %   at all with `TrainTestSplitRatio` and specify
            %   `TestError=false`, so that the error is computed for the whole
            %   new set. Yes, this sounds a bit confusing. default false
            %
            % The method uses the predict method to compute the error. For
            % regression models the error is computed as RMS, for classifiers
            % as a percent of missclassified samples (0%-100%).
            %
            % See also: cv.ANN_MLP.train, cv.ANN_MLP.predict
            %
            [err,resp] = ANN_MLP_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts response(s) for the provided sample(s)
            %
            %     [results,f] = model.predict(samples)
            %     [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ The input samples (one or more) stored as rows of
            %   the floating-point matrix.
            %
            % ## Output
            % * __results__ Predicted responses for corresponding samples.
            % * __f__ Returned when you pass one sample. Otherwise unused and
            %   returns 0.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent.
            %   Not used. default 0
            %
            % See also: cv.ANN_MLP.train, cv.ANN_MLP.calcError
            %
            [results,f] = ANN_MLP_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% ANN_MLP
    methods
        function weights = getWeights(this, layerIdx)
            %GETWEIGHTS  Returns neurons weights of the particular layer
            %
            %     weights = model.getWeights(layerIdx)
            %
            % ## Input
            % * __layerIdx__ zero-based index for the layer.
            %
            % ## Output
            % * __weights__ weights matrix for the specified layer.
            %
            weights = ANN_MLP_(this.id, 'getWeights', layerIdx);
        end

        function setTrainMethod(this, method, varargin)
            %SETTRAINMETHOD  Sets training method and common parameters
            %
            %     model.setTrainMethod(method)
            %     model.setTrainMethod(method, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __method__ Available training methods:
            %   * __Backprop__ The back-propagation algorithm.
            %   * __RProp__ (default) The RPROP algorithm. See [RPROP93] for
            %     details.
            %   * __Anneal__ The simulated annealing algorithm. See
            %     [Kirkpatrick83] for details.
            %
            % ## Options
            % * __Param1__ sets `RpropDW0` property for 'RProp' and sets
            %   `BackpropWeightScale` property for 'Backprop' and sets
            %   `AnnealInitialT` for `Anneal`. default 0
            % * __Param2__ sets `RpropDWMin` property for 'RProp' and sets
            %   `BackpropMomentumScale` property for 'Backprop' and sets
            %   `AnnealFinalT` for `Anneal`. default 0
            %
            % ## References
            % [RPROP93]:
            % > Martin Riedmiller and Heinrich Braun. "A direct adaptive method
            % > for faster backpropagation learning: The rprop algorithm".
            % > In Neural Networks, 1993., IEEE International Conference on,
            % > pages 586-591. IEEE, 1993.
            %
            % [Kirkpatrick83]:
            % > S. Kirkpatrick, C. D. Jr Gelatt, and M. P. Vecchi.
            % > "Optimization by simulated annealing". Science,
            % > 220(4598):671-680, 1983.
            %
            % See also: cv.ANN_MLP.TrainMethod
            %
            ANN_MLP_(this.id, 'setTrainMethod', method, varargin{:});
        end

        function setActivationFunction(this, ftype, varargin)
            %SETACTIVATIONFUNCTION  Initialize the activation function for each neuron
            %
            %     model.setActivationFunction(ftype)
            %     model.setActivationFunction(ftype, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __ftype__ The type of activation function. default 'Sigmoid'.
            %   Possible activation functions:
            %   * __Identity__ Identity function: `f(x) = x`
            %   * __Sigmoid__ Symmetrical sigmoid:
            %     `f(x) = beta * (1-exp(-alpha*x))/(1+exp(-alpha*x))`. See
            %     note below.
            %   * __Gaussian__ Gaussian function:
            %     `f(x) = beta * exp(-alpha^2*x*x)`
            %   * __ReLU__ ReLU function: `f(x) = max(0,x)`
            %   * __LeakyReLU__ Leaky ReLU function: `f(x) = x, for x>0` and
            %     `f(x) = alpha*x, for x<=0`
            %
            % ## Options
            % * __Param1__ The first parameter of the activation function,
            %   `alpha`. default 0
            % * __Param2__ The second parameter of the activation function,
            %   `beta`. default 0
            %
            % Currently the default and the only fully supported activation
            % function is 'Sigmoid'.
            %
            % ### Note
            % If you are using the default `Sigmoid` activation function with
            % the default parameter values `Param1=0` and `Param2=0` then the
            % function used is `y = 1.7159*tanh(2/3 * x)`, so the output will
            % range from [-1.7159, 1.7159], instead of [0,1].
            % Recall that by definition
            % `tanh(x) = (1 - exp(-2*x)) / (1 + exp(-2*x))`.
            %
            % See also: cv.ANN_MLP.ActivationFunction
            %
            ANN_MLP_(this.id, 'setActivationFunction', ftype, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.TrainMethod(this)
            value = ANN_MLP_(this.id, 'get', 'TrainMethod');
        end
        function set.TrainMethod(this, value)
            ANN_MLP_(this.id, 'set', 'TrainMethod', value);
        end

        function set.ActivationFunction(this, value)
            ANN_MLP_(this.id, 'set', 'ActivationFunction', value);
        end

        function value = get.LayerSizes(this)
            value = ANN_MLP_(this.id, 'get', 'LayerSizes');
        end
        function set.LayerSizes(this, value)
            ANN_MLP_(this.id, 'set', 'LayerSizes', value);
        end

        function value = get.TermCriteria(this)
            value = ANN_MLP_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            ANN_MLP_(this.id, 'set', 'TermCriteria', value);
        end

        function value = get.BackpropWeightScale(this)
            value = ANN_MLP_(this.id, 'get', 'BackpropWeightScale');
        end
        function set.BackpropWeightScale(this, value)
            ANN_MLP_(this.id, 'set', 'BackpropWeightScale', value);
        end

        function value = get.BackpropMomentumScale(this)
            value = ANN_MLP_(this.id, 'get', 'BackpropMomentumScale');
        end
        function set.BackpropMomentumScale(this, value)
            ANN_MLP_(this.id, 'set', 'BackpropMomentumScale', value);
        end

        function value = get.RpropDW0(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDW0');
        end
        function set.RpropDW0(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDW0', value);
        end

        function value = get.RpropDWPlus(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWPlus');
        end
        function set.RpropDWPlus(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWPlus', value);
        end

        function value = get.RpropDWMinus(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWMinus');
        end
        function set.RpropDWMinus(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWMinus', value);
        end

        function value = get.RpropDWMin(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWMin');
        end
        function set.RpropDWMin(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWMin', value);
        end

        function value = get.RpropDWMax(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWMax');
        end
        function set.RpropDWMax(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWMax', value);
        end

        function value = get.AnnealInitialT(this)
            value = ANN_MLP_(this.id, 'get', 'AnnealInitialT');
        end
        function set.AnnealInitialT(this, value)
            ANN_MLP_(this.id, 'set', 'AnnealInitialT', value);
        end

        function value = get.AnnealFinalT(this)
            value = ANN_MLP_(this.id, 'get', 'AnnealFinalT');
        end
        function set.AnnealFinalT(this, value)
            ANN_MLP_(this.id, 'set', 'AnnealFinalT', value);
        end

        function value = get.AnnealCoolingRatio(this)
            value = ANN_MLP_(this.id, 'get', 'AnnealCoolingRatio');
        end
        function set.AnnealCoolingRatio(this, value)
            ANN_MLP_(this.id, 'set', 'AnnealCoolingRatio', value);
        end

        function value = get.AnnealItePerStep(this)
            value = ANN_MLP_(this.id, 'get', 'AnnealItePerStep');
        end
        function set.AnnealItePerStep(this, value)
            ANN_MLP_(this.id, 'set', 'AnnealItePerStep', value);
        end
    end

end
