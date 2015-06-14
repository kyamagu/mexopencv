classdef ANN_MLP < handle
    %ANN_MLP Neural Networks
    %
    % ML implements feed-forward artificial neural networks or, more
    % particularly, multi-layer perceptrons (MLP), the most commonly used type
    % of neural networks. MLP consists of the input layer, output layer, and one
    % or more hidden layers. Each layer of MLP includes one or more neurons
    % directionally linked with the neurons from the previous and the next layer.
    %
    % All the neurons in MLP are similar. Each of them has several input links
    % (it takes the output values from several neurons in the previous layer as
    % input) and several output links (it passes the response to several neurons
    % in the next layer). The values retrieved from the previous layer are
    % summed up with certain weights, individual for each neuron, plus the bias
    % term. The sum is transformed using the activation function  that may be
    % also different for different neurons.
    %
    % In other words, given the outputs `x_j` of the layer `n`, the outputs `y_i` of
    % the layer `n+1` are computed as:
    %
    %    u_i = \sum_j (w_{i,j}^{n+1} * x_j) + w_{i,bias}^{n+1}
    %    y_i = f(u_i)
    %
    % Different activation functions may be used. OpenCV implements three
    % standard functions:
    %
    % * Identity:
    %
    %        f(x) = y
    %
    % * Symmetrical sigmoid: (default)
    %
    %        f(x) = \beta * (1-\exp{- \alpha * x}) / (1+\exp{- \alpha * x})
    %
    % * Gaussian function:
    %
    %        f(x) = \beta * \exp{- \alpha * x * x}
    %
    % In OpenCV, all the neurons have the same activation functions, with the
    % same free parameters (\alpha,\beta) that are specified by user and are
    % not altered by the training algorithms.
    %
    % So, the whole trained network works as follows:
    %
    % 1.  Take the feature vector as input. The vector size is equal to the
    %     size of the input layer.
    % 2.  Pass values as input to the first hidden layer.
    % 3.  Compute outputs of the hidden layer using the weights and the
    %     activation functions.
    % 4.  Pass outputs further downstream until you compute the output layer.
    %
    % So, to compute the network, you need to know all the weights `w_{i,j}^{n+1}`.
    % The weights are computed by the training algorithm. The algorithm takes a
    % training set, multiple input vectors with the corresponding output vectors,
    % and iteratively adjusts the weights to enable the network to give the
    % desired response to the provided input vectors.
    %
    % The larger the network size (the number of hidden layers and their sizes)
    % is, the more the potential network flexibility is. The error on the
    % training set could be made arbitrarily small. But at the same time the
    % learned network also learn the noise present in the training set, so
    % the error on the test set usually starts increasing after the network size
    % reaches a limit. Besides, the larger networks are trained much longer than
    % the smaller ones, so it is reasonable to pre-process the data, using PCA
    % or similar technique, and train a smaller network on only essential
    % features.
    %
    % Another MPL feature is an inability to handle categorical data as is.
    % However, there is a workaround. If a certain feature in the input or
    % output (in case of n-class classifier for n>2) layer is categorical and
    % can take M>2 different values, it makes sense to represent it as a binary
    % tuple of M elements, where the i-th element is 1 if and only if the
    % feature is equal to the i-th value out of M possible. It increases the
    % size of the input/output layer but speeds up the training algorithm
    % convergence and at the same time enables fuzzy values of such variables,
    % that is, a tuple of probabilities instead of a fixed value.
    %
    % OpenCV implements two algorithms for training MLP's.The first algorithm
    % is a classical random sequential back-propagation algorithm. The second
    % (default) one is a batch RPROP algorithm.
    %
    % * [BackPropWikipedia] http://en.wikipedia.org/wiki/Backpropagation.
    %   Wikipedia article about the back-propagation algorithm.
    % * [LeCun98] LeCun, L. Bottou, G.B. Orr and K.-R. Muller, Efficient backprop,
    %   in Neural Networks Tricks of the Trade, Springer Lecture Notes in
    %   Computer Sciences 1524, pp.5-50, 1998.
    % * [RPROP93] M. Riedmiller and H. Braun, A Direct Adaptive Method for Faster
    %   Backpropagation Learning: The RPROP Algorithm, Proc. ICNN, San
    %   Francisco (1993).
    %
    % See also cv.ANN_MLP.ANN_MLP cv.ANN_MLP.train
    % cv.ANN_MLP.predict
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % Integer vector specifying the number of neurons in each layer
        % including the input and output layers. The very first element
        % specifies the number of elements in the input layer. The last
        % element, number of elements in the output layer. default empty
        LayerSizes
        % Termination criteria of the training algorithm. You can specify the
        % maximum number of iterations (`maxCount`) and/or how much the error
        % could change between the iterations to make the algorithm continue
        % (`epsilon`). Default value is
        % `struct('type','Count+EPS', 'maxCount',1000, 'epsilon',0.01)`.
        TermCriteria
        % Current training method. default 'RProp'
        TrainMethod
        % BPROP: Strength of the weight gradient term. The recommended value
        % is about 0.1. Default value is 0.1.
        BackpropWeightScale
        % BPROP: Strength of the momentum term (the difference between weights
        % on the 2 previous iterations). This parameter provides some inertia
        % to smooth the random fluctuations of the weights. It can vary from
        % 0 (the feature is disabled) to 1 and beyond. The value 0.1 or so is
        % good enough. Default value is 0.1.
        BackpropMomentumScale
        % RPROP: Initial value `delta_0` of update-values `delta_ij`.
        % Default value is 0.1.
        RpropDW0
        % RPROP: Increase factor `eta_plus`. It must be >1.
        % Default value is 1.2.
        RpropDWPlus
        % RPROP: Decrease factor `eta_minus`. It must be <1.
        % Default value is 0.5.
        RpropDWMinus
        % RPROP: Update-values lower limit `delta_min`. It must be positive.
        % Default value is `eps('single')`.
        RpropDWMin
        % RPROP: Update-values upper limit `delta_max`. It must be >1.
        % Default value is 50.
        RpropDWMax
    end

    properties (Dependent, GetAccess = private)
        % Activation function for all neurons. default 'Sigmoid'
        % (with `alpha=0` and `beta=0`)
        % **Note**: If you are using the default sigmoid activation function
        % with the default parameter values `Param1=0` and `Param2=0` then the
        % function used is `y = 1.7159*tanh(2/3 * x)`, so the output will
        % range from [-1.7159, 1.7159], instead of [0,1].
        ActivationFunction
    end

    methods
        function this = ANN_MLP()
            %ANN_MLP  Constructs MLP model
            %
            %    classifier = cv.ANN_MLP()
            %
            % Creates an empty model.
            %
            % Use cv.ANN_MLP.train to train the model, cv.ANN_MLP.load to load
            % the pre-trained model. Note that the train method has optional
            % flags.
            %
            % See also cv.ANN_MLP
            %
            this.id = ANN_MLP_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.ANN_MLP
            %
            ANN_MLP_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.ANN_MLP.empty
            %
            ANN_MLP_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty.
            %
            %    obj.empty()
            %
            % (e.g. in the very beginning or after unsuccessful read).
            %
            b = ANN_MLP_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier.
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.ANN_MLP.save, cv.ANN_MLP.load
            %
            name = ANN_MLP_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file.
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.ANN_MLP.load
            %
            ANN_MLP_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string.
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model.
            %       default false
            %
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.ANN_MLP.save
            %
            ANN_MLP_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% StatModel
    methods
        function count = getVarCount(this)
            %GETVARCOUNT  Returns the number of variables in training samples.
            %
            %    count = model.getVarCount()
            %
            % ## Output
            % * __count__
            %
            count = ANN_MLP_(this.id, 'getVarCount');
        end

        function b = isClassifier(this)
            %ISCLASSIFIER  Returns true if the model is classifier.
            %
            %    b = model.isClassifier()
            %
            % ## Output
            % * __b__
            %
            b = ANN_MLP_(this.id, 'isClassifier');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained.
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__
            %
            b = ANN_MLP_(this.id, 'isTrained');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains the model
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(trainData, responses, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __trainData__ Row vectors of feature.
            % * __responses__  Output of the corresponding feature vectors.
            %
            % ## Options
            % * __TrainMethod__ Training method of the MLP. Possible values
            %     are shown below. default 'RProp'.
            %     * 'BackProp' The back-propagation algorithm
            %     * 'RProp'    The RPROP algorithm
            % * __SampleWeights__ (RProp only) Optional floating-point vector
            %     of weights for each sample. Some samples may be more
            %     important than others for training. You may want to raise
            %     the weight of certain classes to find the right balance
            %     between hit-rate and false-alarm rate, and so on.
            % * __SampleIdx__ Indicator samples of interest. Must have the
            %     the same size to responses.
            % * __UpdateWeights__ Algorithm updates the network weights, rather
            %     than computes them from scratch. In the latter case the
            %     weights are initialized using the Nguyen-Widrow algorithm.
            %     default false.
            % * __NoInputScale__ Algorithm does not normalize the input vectors.
            %     If this flag is not set, the training algorithm normalizes
            %     each input feature independently, shifting its mean value
            %     to 0 and making the standard deviation equal to 1. If the
            %     network is assumed to be updated frequently, the new
            %     training data could be much different from original one.
            %     In this case, you should take care of proper normalization.
            %     default false.
            % * __NoOutputScale__ Algorithm does not normalize the output
            %     vectors. If the flag is not set, the training algorithm
            %     normalizes each output feature independently, by
            %     transforming it to the certain range depending on the used
            %     activation function. default false.
            % * __TermCrit__ Termination criteria of the training algorithm.
            %     You can specify the maximum number of iterations
            %     (max_iter) and/or how much the error could change between
            %     the iterations to make the algorithm continue (epsilon).
            %     A struct with the following fields are accepted:
            %     * 'type'      one of {'Count','EPS','Count+EPS'}
            %     * 'maxCount'  maximum number of iterations
            %     * 'epsilon'   tolerance value
            % * __BpDwScale__ (BackProp only) Strength of the weight gradient
            %     term. The recommended value is about 0.1 (default)
            % * __BpMomentScale__ (BackProp only) Strength of the momentum
            %     term (the difference between weights on the 2 previous
            %     iterations). This parameter provides some inertia to
            %     smooth the random fluctuations of the weights. It can
            %     vary from 0 (the feature is disabled) to 1 and beyond.
            %     The value 0.1 (default) or so is good enough.
            % * __RpDw0__ Initial value Delta0 of update-values Delta_ij.
            %     default 0.1.
            % * __RpDwPlus__ Increase factor eta^+. It must be >1. default 1.2
            % * __RpDwMinus__ Decrease factor eta^-. It must be <1. default 0.5
            % * __RpDwMin__ Update-values lower limit Delta_min. It must be
            %     positive. default FLT_EPSILON
            % * __RpDwMax__ Update-values upper limit Delta_max. It must be
            %     >1. default 50
            %
            % The method trains the ANN_MLP model.
            %
            % See also cv.ANN_MLP cv.ANN_MLP.predict
            %
            status = ANN_MLP_(this.id, 'train_', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts the response for input samples.
            %
            %    results = classifier.predict(samples)
            %
            % The method estimates the most probable classes for input vectors.
            % Input vectors (one or more) are stored as rows of the matrix
            % samples.
            %
            % See also cv.ANN_MLP cv.ANN_MLP.train
            %
            [results,f] = ANN_MLP_(this.id, 'predict', samples, varargin{:});
        end

        function [resp,err] = calcError(this, samples, responses, test, varargin)
            %CALCERROR
            %
            [resp,err] = ANN_MLP_(this.id, 'calcError', samples, responses, test, varargin{:});
        end

        function weights = getWeights(this, layerIdx)
            %GETWEIGHTS  Returns neurons weights of the particular layer
            %
            % ## Input
            % * __layerIdx__ zero-based index for the layer.
            %
            % ## Output
            % * __weights__ weights matrix for the specified layer.
            %
            weights = ANN_MLP_(this.id, 'getWeights', layerIdx);
        end

        function setActivationFunction(this, ftype, varargin)
            %SETACTIVATIONFUNCTION  Initialize the activation function for each neuron.
            %
            %    classifier.setActivationFunction(ftype)
            %    classifier.setActivationFunction(ftype, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __ftype__: The type of activation function. default 'Sigmoid'.
            %       Possible activation functions:
            %       * __'Identity'__ Identity function: `f(x) = x`
            %       * __'Sigmoid'__ Symmetrical sigmoid:
            %             `f(x) = beta * (1-exp(-alpha*x))/(1+exp(-alpha*x))`
            %       * __'Gaussian'__ Gaussian function:
            %             `f(x) = beta * exp(-alpha*x*x)`
            %
            % ## Options
            % * __Param1__ The first parameter of the activation function,
            %       `alpha`. default 0
            % * __Param2__: The second parameter of the activation function,
            %       `beta`. default 0
            %
            % Currently the default and the only fully supported activation
            % function is 'Sigmoid'.
            %
            ANN_MLP_(this.id, 'setActivationFunction', ftype, varargin{:});
        end

        function setTrainMethod(this, method, varargin)
            %SETTRAINMETHOD  Sets training method and common parameters.
            %
            %    classifier.setTrainMethod(method)
            %    classifier.setTrainMethod(method, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __method__ Available training methods:
            %       * __'Backprop'__ The back-propagation algorithm.
            %       * __'RProp'__ (default) The RPROP algorithm. See [101]
            %             for details.
            %
            % ## Options
            % * __Param1__ passed to `RpropDW0` for 'RProp' and to
            %       `BackpropWeightScale` for 'Backprop'. default 0
            % * __Param2__: passed to `RpropDWMin` for 'RProp' and to
            %       `BackpropMomentumScale` for 'Backprop'. default 0
            %
            % ## References
            % [101]:
            % > Martin Riedmiller and Heinrich Braun. "A direct adaptive method
            % for faster backpropagation learning: The rprop algorithm".
            % > In Neural Networks, 1993., IEEE International Conference on,
            % > pages 586-591. IEEE, 1993.
            %
            ANN_MLP_(this.id, 'setTrainMethod', method, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.BackpropMomentumScale(this)
            value = ANN_MLP_(this.id, 'get', 'BackpropMomentumScale');
        end
        function set.BackpropMomentumScale(this, value)
            ANN_MLP_(this.id, 'set', 'BackpropMomentumScale', value);
        end

        function value = get.BackpropWeightScale(this)
            value = ANN_MLP_(this.id, 'get', 'BackpropWeightScale');
        end
        function set.BackpropWeightScale(this, value)
            ANN_MLP_(this.id, 'set', 'BackpropWeightScale', value);
        end

        function value = get.LayerSizes(this)
            %LAYERSIZES  Returns numbers of neurons in each layer of the MLP
            %
            % This returns the integer vector specifying the number of neurons
            % in each layer including the input and output layers of the MLP.
            %
            value = ANN_MLP_(this.id, 'get', 'LayerSizes');
        end
        function set.LayerSizes(this, value)
            %LAYERSIZES
            %
            % Integer vector specifying the number of neurons in
            % each layer including the input and output layers. The first
            % element must be the size of the inputs (feature dimensions)
            % and the last element must be the size of outputs (regression
            % dimensions). For example, [N,1] means two-layer network that
            % takes an N-dimensional vector as an input and output scalar.
            %
            ANN_MLP_(this.id, 'set', 'LayerSizes', value);
        end

        function value = get.RpropDW0(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDW0');
        end
        function set.RpropDW0(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDW0', value);
        end

        function value = get.RpropDWMax(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWMax');
        end
        function set.RpropDWMax(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWMax', value);
        end

        function value = get.RpropDWMin(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWMin');
        end
        function set.RpropDWMin(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWMin', value);
        end

        function value = get.RpropDWMinus(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWMinus');
        end
        function set.RpropDWMinus(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWMinus', value);
        end

        function value = get.RpropDWPlus(this)
            value = ANN_MLP_(this.id, 'get', 'RpropDWPlus');
        end
        function set.RpropDWPlus(this, value)
            ANN_MLP_(this.id, 'set', 'RpropDWPlus', value);
        end

        function value = get.TermCriteria(this)
            value = ANN_MLP_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            ANN_MLP_(this.id, 'set', 'TermCriteria', value);
        end

        function value = get.TrainMethod(this)
            value = ANN_MLP_(this.id, 'get', 'TrainMethod');
        end
        function set.TrainMethod(this, value)
            ANN_MLP_(this.id, 'set', 'TrainMethod', value);
        end

        %function value = get.ActivationFunction(this)
        %    value = ANN_MLP_(this.id, 'get', 'ActivationFunction');
        %end
        function set.ActivationFunction(this, value)
            ANN_MLP_(this.id, 'set', 'ActivationFunction', value);
        end
    end

end
