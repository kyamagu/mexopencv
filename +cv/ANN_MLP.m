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
% See also cv.ANN_MLP.ANN_MLP cv.ANN_MLP.create cv.ANN_MLP.train
% cv.ANN_MLP.predict
%

properties (SetAccess = private)
    id % Object ID
end

properties (SetAccess = private, Dependent)
end

methods
    function this = ANN_MLP(varargin)
        %ANN_MLP  Constructs MLP model
        %
        %    classifier = cv.ANN_MLP
        %    classifier = cv.ANN_MLP(...)
        %
        % The constructor optionally takes the argument of create method.
        %
        % See also cv.ANN_MLP  cv.ANN_MLP.create
        %
        this.id = ANN_MLP_();
        if nargin>0, this.create(varargin{:}); end
    end

    function delete(this)
        %DELETE  Destructor
        %
        % See also cv.ANN_MLP
        %
        ANN_MLP_(this.id, 'delete');
    end

    function clear(this)
        %CLEAR  Deallocates memory and resets the model state
        %
        %    classifier.clear()
        %
        % The method clear does the same job as the destructor: it 
        % deallocates all the memory occupied by the class members. But
        % the object itself is not destructed and can be reused
        % further. This method is called from the destructor, from the
        % train() methods of the derived classes, from the methods
        % load(), or even explicitly by the user.
        %
        % See also cv.ANN_MLP
        %
        ANN_MLP_(this.id, 'clear');
    end

    function save(this, filename)
        %SAVE  Saves the model to a file
        %
        %    classifier.save(filename)
        %
        % See also cv.ANN_MLP
        %
        ANN_MLP_(this.id, 'save', filename);
    end

    function load(this, filename)
        %LOAD  Loads the model from a file
        %
        %    classifier.load(filename)
        %
        % See also cv.ANN_MLP
        %
        ANN_MLP_(this.id, 'load', filename);
    end

    function create(this, layerSizes)
        %CREATE  Constructs MLP with the specified topology
        %
        %    classifier.create(layerSizes)
        %
        % ## Input
        % * __layerSizes__: Integer vector specifying the number of neurons in
        %     each layer including the input and output layers. The first
        %     element must be the size of the inputs (feature dimensions)
        %     and the last element must be the size of outputs (regression
        %     dimensions). For example, [N,1] means two-layer network that
        %     takes an N-dimensional vector as an input and output scalar.
        %
        % ## Options
        % * __ActivateFunc__: Parameter specifying the activation function
        %     for each neuron: one of 'Identity', 'Sigmoid', 'Gaussian'.
        %     default 'Sigmoid'.
        % * __FParam1__, __FParam2__: Free parameters of the activation
        %     function, alpha and beta, respectively. See the formulas.
        %
        % The method creates an MLP network with the specified topology and
        % assigns the same activation function to all the neurons.
        %
        % See also cv.ANN_MLP cv.ANN_MLP.train
        %
        ANN_MLP_(this.id, 'create', layerSizes);
    end

    function status = train(this, trainData, responses, varargin)
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
        status = ANN_MLP_(this.id, 'train', trainData, responses, varargin{:});
    end

    function results = predict(this, samples)
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
        results = ANN_MLP_(this.id, 'predict', samples);
    end

    function value = get_layer_count(this)
        %GET_LAYER_COUNT  Returns the number of layers in the MLP
        %
        value = ANN_MLP_(this.id, 'get_layer_count');
    end

    function value = get_layer_sizes(this)
        %GET_LAYER_SIZES  Returns numbers of neurons in each layer of the MLP
        %
        % The method returns the integer vector specifying the number of
        % neurons in each layer including the input and output layers of the
        % MLP.
        %
        value = ANN_MLP_(this.id, 'get_layer_sizes');
    end

    function value = get_weights(this, layer)
        %GET_WEIGHTS  Returns neurons weights of the particular layer
        %
        value = ANN_MLP_(this.id, 'get_weights', layer);
    end
end

end
