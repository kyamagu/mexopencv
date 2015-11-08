classdef EM < handle
    %EM  Expectation Maximization Algorithm
    %
    % The class implements the Expectation Maximization algorithm.
    % This is an algorithm to train Gaussian Mixture Models (GMM).
    %
    % ## Expectation Maximization
    %
    % The Expectation Maximization(EM) algorithm estimates the parameters of
    % the multivariate probability density function in the form of a Gaussian
    % mixture distribution with a specified number of mixtures.
    %
    % Consider the set of the `N` feature vectors `{x1,x2,...,xN}` from a
    % `d`-dimensional Euclidean space drawn from a Gaussian mixture:
    %
    %    p(x;a_k,S_k,PI_k) = sum_{k=1..m} PI_k * p_k(x),
    %        PI_k>=0,  sum_{k=1..m}(PI_k)=1
    %
    %    p_k(x) = phi(x;a_k,S_k)
    %           = 1/((2*pi)^(d/2) * |Sk|^(1/2)) *
    %             exp(-0.5 * (x - a_k)' * inv(S_k) * (x - a_k))
    %
    % where `m` is the number of mixtures, `p_k` is the normal distribution
    % density with the mean `a_k` and covariance matrix `S_k`, `PI_k` is the
    % weight of the k-th mixture. Given the number of mixtures `m` and the
    % samples `xi, i=1..N` the algorithm finds the maximum-likelihood
    % estimates (MLE) of all the mixture parameters, that is, `a_k`, `S_k` and
    % `PI_k`:
    %
    %    L(x,theta) = logp(x,theta)
    %               = sum_{i=1..N} log(sum_{k=1..m} PI_k * p_k(x))
    %    -> argmax_{theta IN THETA},
    %
    %    THETA = {(a_k,S_k,PI_k): a_k IN R^d, S_k=S_k'>0, S_k IN R^(dxd),
    %                             PI_k>=0, sum_{k=1..m}(PI_k)=1}
    %
    % The EM algorithm is an iterative procedure. Each iteration includes two
    % steps. At the first step (Expectation step or E-step), you find a
    % probability `p_{i,k}` (denoted `alpha_{i,k}` in the formula below) of
    % sample `i` to belong to mixture `k` using the currently available
    % mixture parameter estimates:
    %
    %    alpha_{k,i} = ( PI_k * phi(x;a_k,S_k) ) /
    %                  sum_{j=1..m} (PI_j * phi(x;a_j,S_j))
    %
    % At the second step (Maximization step or M-step), the mixture parameter
    % estimates are refined using the computed probabilities:
    %
    %    PI_k = (1/N) * sum_{i=1..N}(alpha_{k,i})
    %    a_k = sum_{i=1..N}(alpha_{k,i}*x_i) / sum_{i=1..N}(alpha_{k,i})
    %    S_k = sum_{i=1..N}(alpha_{k,i} * (x_i - a_k)*(x_i - a_k)') /
    %          sum_{i=1..N}(alpha_{k,i})
    %
    % Alternatively, the algorithm may start with the M-step when the initial
    % values for `p_{i,k}` can be provided. Another alternative when `p_{i,k}`
    % are unknown is to use a simpler clustering algorithm to pre-cluster the
    % input samples and thus obtain initial `p_{i,k}`. Often (including
    % machine learning) the k-means algorithm is used for that purpose.
    %
    % One of the main problems of the EM algorithm is a large number of
    % parameters to estimate. The majority of the parameters reside in
    % covariance matrices, which are `dxd` elements each where `d` is the
    % feature space dimensionality. However, in many practical problems, the
    % covariance matrices are close to diagonal or even to `mu_k * I`, where
    % `I` is an identity matrix and `mu_k` is a mixture-dependent "scale"
    % parameter. So, a robust computation scheme could start with harder
    % constraints on the covariance matrices and then use the estimated
    % parameters as an input for a less constrained optimization problem
    % (often a diagonal covariance matrix is already a good enough
    % approximation).
    %
    % ## References
    % [Bilmes98]:
    % > J. A. Bilmes. "A Gentle Tutorial of the EM Algorithm and its
    % > Application to Parameter Estimation for Gaussian Mixture and Hidden
    % > Markov Models". Technical Report TR-97-021, International Computer
    % > Science Institute and Computer Science Division, University of
    % > California at Berkeley, April 1998.
    %
    % See also: cv.EM/EM, cv.EM/train, cv.EM/predict, cv.kmeans, fitgmdist
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The number of mixture components in the Gaussian mixture model.
        %
        % Default value of the parameter is 5. Some of EM implementation could
        % determine the optimal number of mixtures within a specified value
        % range, but that is not the case in ML yet. Must be at least 2.
        ClustersNumber

        % Constraint on covariance matrices which defines type of matrices.
        %
        % Possible values:
        %
        % * __Spherical__ A scaled identity matrix `mu_k*I`. There is the only
        %       parameter `mu_k` to be estimated for each matrix. The option
        %       may be used in special cases, when the constraint is relevant,
        %       or as a first step in the optimization (for example in case
        %       when the data is preprocessed with cv.PCA). The results of
        %       such preliminary estimation may be passed again to the
        %       optimization procedure, this time with
        %       `CovarianceMatrixType='Diagonal'`.
        % * __Diagonal__ A diagonal matrix with positive diagonal elements.
        %       The number of free parameters is `d` for each matrix. This is
        %       most commonly used option yielding good estimation results.
        % * __Generic__ A symmetric positively defined matrix. The number of
        %       free parameters in each matrix is about `d^2/2`. It is not
        %       recommended to use this option, unless there is pretty
        %       accurate initial estimation of the parameters and/or a huge
        %       number of training samples.
        % * __Default__ Synonym for 'Diagonal'. This is the default.
        CovarianceMatrixType

        % The termination criteria of the EM algorithm.
        %
        % The EM algorithm can be terminated by the number of iterations
        % `TermCriteria.maxCount` (number of M-steps) or when relative change
        % of likelihood logarithm is less than `TermCriteria.epsilon`. Default
        % is `struct('type','Count+EPS', 'maxCount',100, 'epsilon',1e-6)`.
        TermCriteria
    end

    %% Constructor/destructor
    methods
        function this = EM(varargin)
            %EM  EM constructor
            %
            %    model = cv.EM()
            %    model = cv.EM(filename)
            %
            % Creates empty EM model. The model should be trained then using
            % train method. Alternatively, you can use one of the other train*
            % methods or load it from file using load method.
            %
            % In the second form (with given file name as an input), the new
            % object is created, which then loads parameters (options, trained
            % weights, means and covariations) which were saved to this file
            % by some earlier created object.
            %
            % ## Input
            % * __filename__ Name of XML or YML file, containing
            %       previously saved model
            %
            % See also: cv.EM, cv.EM/train, cv.EM/load
            %
            this.id = EM_(0, 'new');
            if nargin > 0
                this.load(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.EM
            %
            EM_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    model.clear()
            %
            % The method clear does the same job as the destructor: it
            % deallocates all the memory occupied by the class members. But
            % the object itself is not destructed and can be reused further.
            % This method is called from the destructor, from the train() and
            % load() methods, or even explicitly by the user.
            %
            % See also: cv.EM/empty, cv.EM/load
            %
            EM_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %    b = model.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %       beginning or after unsuccessful read).
            %
            % See also: cv.EM/clear, cv.EM/load
            %
            b = EM_(this.id, 'empty');
        end

        function varargout = save(this, filename)
            %SAVE  Saves the algorithm parameters to a file or a string
            %
            %    model.save(filename)
            %    str = model.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to. In case of string
            %       output, only the filename extension is used to determine
            %       the output format (XML or YAML).
            %
            % ## Output
            % * __str__ optional output. If requested, the model is persisted
            %       to a string in memory instead of writing to disk.
            %
            % This method stores the complete model state to the specified
            % XML or YAML file (or to a string in memory, based on the number
            % of output arguments).
            %
            % See also: cv.EM/load
            %
            [varargout{1:nargout}] = EM_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %    model.load(filename)
            %    model.load(str, 'FromString',true)
            %    model.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model
            %       (switches between `Algorithm<T>::load()` and
            %       `Algorithm<T>::loadFromString()` C++ methods).
            %       default false
            %
            % This method loads the complete model state from the specified
            % XML or YAML file (either from disk or serialized string). The
            % previous model state is cleared.
            %
            % See also: cv.EM/save
            %
            EM_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %    name = model.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.EM/save, cv.EM/load
            %
            name = EM_(this.id, 'getDefaultName');
        end
    end

    %% StatModel
    methods
        function count = getVarCount(this)
            %GETVARCOUNT  Returns the number of variables in training samples
            %
            %    count = model.getVarCount()
            %
            % ## Output
            % * __count__ number of variables in training samples.
            %
            % See also: cv.EM/train
            %
            count = EM_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.EM/empty, cv.EM/train
            %
            b = EM_(this.id, 'isTrained');
        end

        function b = isClassifier(this)
            %ISCLASSIFIER  Returns true if the model is a classifier
            %
            %    b = model.isClassifier()
            %
            % ## Output
            % * __b__ Returns true if the model is a classifier, false if the
            %       model is a regressor.
            %
            % Always true for EM.
            %
            % See also: cv.EM/isTrained
            %
            b = EM_(this.id, 'isClassifier');
        end

        function status = train(this, samples, varargin)
            %TRAIN  Estimates the Gaussian mixture parameters from a samples set
            %
            %    status = model.train(samples)
            %    status = model.train(csvFilename)
            %    [...] = model.train(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will
            %       be estimated. It should be a floating-point matrix, each
            %       row of which is a sample (see the `Layout` option).
            %       Internally the computations are performed in `double`
            %       precision type.
            % * __csvFilename__ The input CSV file name from which to load
            %       dataset. In this variant, you should set the second
            %       argument to an empty array.
            %
            % ## Output
            % * __status__ The method returns true if the Gaussian mixture
            %       model was trained successfully, otherwise it returns
            %       false.
            %
            % ## Options
            % * __Data__ Training data options, specified as a cell array of
            %       key/value pairs of the form `{'key',val, ...}`. See below.
            % * __Flags__ The optional training flags, model-dependent.
            %       Not used. default 0
            %
            % ### Options for `Data` (first variant with samples and reponses)
            % * __Layout__ Sample types. Default 'Row'. One of:
            %       * __Row__ each training sample is a row of samples.
            %       * __Col__ each training sample occupies a column of
            %             samples.
            % * __VarIdx__ vector specifying which variables to use for
            %       training. It can be an integer vector (`int32`) containing
            %       0-based variable indices or logical vector (`uint8` or
            %       `logical`) containing a mask of active variables. Not set
            %       by default, which uses all variables in the input data.
            % * __SampleIdx__ vector specifying which samples to use for
            %       training. It can be an integer vector (`int32`) containing
            %       0-based sample indices or logical vector (`uint8` or
            %       `logical`) containing a mask of training samples of
            %       interest. Not set by default, which uses all samples in
            %       the input data.
            % * __SampleWeights__ optional floating-point vector with weights
            %       for each sample. Some samples may be more important than
            %       others for training. You may want to raise the weight of
            %       certain classes to find the right balance between hit-rate
            %       and false-alarm rate, and so on. Not set by default, which
            %       effectively assigns an equal weight of 1 for all samples.
            % * __VarType__ optional vector of type `uint8` and size
            %       `<num_of_vars_in_samples> + <num_of_vars_in_responses>`,
            %       containing types of each input and output variable. By
            %       default considers all variables as numerical (both input
            %       and output variables). In case there is only one output
            %       variable of integer type, it is considered categorical.
            %       You can also specify a cell-array of strings (or as one
            %       string of single characters, e.g 'NNNC'). Possible values:
            %       * __Numerical__, __N__ same as 'Ordered'
            %       * __Ordered__, __O__ ordered variables
            %       * __Categorical__, __C__ categorical variables
            % * __MissingMask__ Indicator mask for missing observation (not
            %       currently implemented). Not set by default
            % * __TrainTestSplitCount__ divides the dataset into train/test
            %       sets, by specifying number of samples to use for the test
            %       set. By default all samples are used for the training set.
            % * __TrainTestSplitRatio__ divides the dataset into train/test
            %       sets, by specifying ratio of samples to use for the test
            %       set. By default all samples are used for the training set.
            % * __TrainTestSplitShuffle__ when splitting dataset into
            %       train/test sets, specify whether to shuffle the samples.
            %       Otherwise samples are assigned sequentially (first train
            %       then test). default true
            %
            % ### Options for `Data` (second variant for loading CSV file)
            % * __HeaderLineCount__ The number of lines in the beginning to
            %       skip; besides the header, the function also skips empty
            %       lines and lines staring with '#'. default 1
            % * __ResponseStartIdx__ Index of the first output variable. If
            %       -1, the function considers the last variable as the
            %       response. default -1
            % * __ResponseEndIdx__ Index of the last output variable + 1. If
            %       -1, then there is single response variable at
            %       `ResponseStartIdx`. default -1
            % * __VarTypeSpec__ The optional text string that specifies the
            %       variables' types. It has the format
            %       `ord[n1-n2,n3,n4-n5,...]cat[n6,n7-n8,...]`. That is,
            %       variables from `n1` to `n2` (inclusive range), `n3`, `n4`
            %       to `n5` ... are considered ordered and `n6`, `n7` to
            %       `n8` ... are considered as categorical. The range
            %       `[n1..n2] + [n3] + [n4..n5] + ... + [n6] + [n7..n8]`
            %       should cover all the variables. If `VarTypeSpec` is not
            %       specified, then algorithm uses the following rules:
            %       * all input variables are considered ordered by default.
            %         If some column contains has non- numerical values, e.g.
            %         'apple', 'pear', 'apple', 'apple', 'mango', the
            %         corresponding variable is considered categorical.
            %       * if there are several output variables, they are all
            %         considered as ordered. Errors are reported when
            %         non-numerical values are used.
            %       * if there is a single output variable, then if its values
            %         are non-numerical or are all integers, then it's
            %         considered categorical. Otherwise, it's considered
            %         ordered.
            % * __Delimiter__ The character used to separate values in each
            %       line. default ','
            % * __Missing__ The character used to specify missing
            %       measurements. It should not be a digit. Although it's a
            %       non-numerical value, it surely does not affect the
            %       decision of whether the variable ordered or categorical.
            %       default '?'
            % * __TrainTestSplitCount__ same as above.
            % * __TrainTestSplitRatio__ same as above.
            % * __TrainTestSplitShuffle__ same as above.
            %
            % The method is an alias for cv.EM.trainEM.
            %
            % There are three versions of the training method that differ in
            % the initialization of Gaussian mixture model parameters and
            % start step:
            %
            % * __trainEM__ Starts with Expectation step. Initial values of
            %       the model parameters will be estimated by the k-means
            %       algorithm.
            % * __trainE__ Starts with Expectation step. You need to provide
            %       initial means `a_k` of mixture components. Optionally you
            %       can pass initial weights `PI_k` and covariance matrices
            %       `S_k` of mixture components.
            % * __trainM__ Starts with Maximization step. You need to provide
            %       initial probabilities `p_{i,k}` to use this option.
            %
            % See also: cv.EM/predict, cv.EM/trainE, cv.EM/trainM, cv.EM/trainEM
            %
            status = EM_(this.id, 'train', samples, varargin{:});
        end

        function [err,resp] = calcError(this, samples, responses, varargin)
            %CALCERROR  Computes error on the training or test dataset
            %
            %    err = model.calcError(samples, responses)
            %    err = model.calcError(csvFilename, [])
            %    [err,resp] = model.calcError(...)
            %    [...] = model.calcError(..., 'OptionName', optionValue, ...)
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
            %       subset of the data, otherwise it's computed over the
            %       training subset of the data. Please note that if you
            %       loaded a completely different dataset to evaluate an
            %       already trained classifier, you will probably want not to
            %       set the test subset at all with `TrainTestSplitRatio` and
            %       specify `TestError=false`, so that the error is computed
            %       for the whole new set. Yes, this sounds a bit confusing.
            %       default false
            %
            % The method uses the predict method to compute the error. For
            % regression models the error is computed as RMS, for classifiers
            % as a percent of missclassified samples (0%-100%).
            %
            % See also: cv.EM/train, cv.EM/predict
            %
            [err,resp] = EM_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts response(s) for the provided sample(s)
            %
            %    [results,f] = model.predict(samples)
            %    [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ The input samples, floating-point matrix.
            %
            % ## Output
            % * __results__ Output matrix of posterior probabilities of each
            %       component given a sample. A matrix of size
            %       `nsamples-by-ClustersNumber` size.
            % * __f__ If you pass one sample then this returns the index of
            %       the most probable mixture component for the given sample.
            %       Otherwise the result for the first sample is returned.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent.
            %       Not used. default 0
            %
            % See also: cv.EM/predict2, cv.EM/train, cv.EM/calcError
            %
            [~, labels, results] = this.predict2(samples);
            f = labels(1);
            %TODO: https://github.com/Itseez/opencv/issues/5443
            %[results,f] = EM_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% EM
    methods
        function weights = getWeights(this)
            %GETWEIGHTS  Returns weights of the mixtures
            %
            %    weights = model.getWeights()
            %
            % ## Output
            % * __weights__ vector of mixtures weights.
            %
            % Returns vector with the number of elements equal to the number
            % of mixtures.
            %
            % See also: cv.EM/getMeans, cv.EM/getCovs
            %
            weights = EM_(this.id, 'getWeights');
        end

        function means = getMeans(this)
            %GETMEANS  Returns the cluster centers (means of the Gaussian mixture)
            %
            %    means = model.getMeans()
            %
            % ## Output
            % * __means__ matrix of cluster means.
            %
            % Returns matrix with the number of rows equal to the number of
            % mixtures and number of columns equal to the space
            % dimensionality.
            %
            % See also: cv.EM/getCovs, cv.EM/getWeights
            %
            means = EM_(this.id, 'getMeans');
        end

        function covs = getCovs(this)
            %GETCOVS  Returns covariation matrices
            %
            %    covs = model.getCovs()
            %
            % ## Output
            % * __covs__ cell array of covariance matrices.
            %
            % Returns vector of covariation matrices. Number of matrices is
            % the number of gaussian mixtures, each matrix is a square
            % floating-point matrix `NxN`, where `N` is the space
            % dimensionality.
            %
            % See also: cv.EM/getMeans, cv.EM/getWeights
            %
            covs = EM_(this.id, 'getCovs');
        end

        function [logLikelihoods, labels, probs] = trainEM(this, samples)
            %TRAINEM  Estimate the Gaussian mixture parameters from a samples set
            %
            %    [logLikelihoods, labels, probs] = model.trainEM(samples)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will
            %       be estimated. It should be a one-channel matrix, each row
            %       of which is a sample. If the matrix does not have `double`
            %       type it will be converted to the inner matrix of such type
            %       for the further computing.
            %
            % ## Output
            % * __logLikelihoods__ The optional output matrix that contains a
            %       likelihood logarithm value for each sample. It has
            %       `nsamples-by-1` size and `double` type.
            % * __labels__ The optional output "class label" for each sample:
            %       `labels_i = argmax_{k}(p_{i,k}), i=1..N` (indices of the
            %       most probable mixture component for each sample). It has
            %       `nsamples-by-1` size and `single` type.
            % * __probs__ The optional output matrix that contains posterior
            %       probabilities of each Gaussian mixture component given the
            %       each sample. It has `nsamples-by-ClustersNumber` size and
            %       `double` type.
            %
            % This variation starts with Expectation step. Initial values of
            % the model parameters will be estimated by the k-means algorithm.
            %
            % Unlike many of the ML models, EM is an unsupervised learning
            % algorithm and it does not take `responses` (class labels or
            % function values) as input. Instead, it computes the Maximum
            % Likelihood Estimate of the Gaussian mixture parameters from an
            % input sample set, stores all the parameters inside the
            % structure: `p_{i,k}` in `probs`, `a_k` in `means` , `S_k` in
            % `covs[k]`, `PI_k` in `weights`, and optionally computes the
            % output "class label" for each sample:
            % `labels_i = argmax_{k}(p_{i,k}), i=1..N` (indices of the most
            % probable mixture component for each sample).
            %
            % The trained model can be used further for prediction, just like
            % any other classifier. The trained model is similar to the
            % cv.NormalBayesClassifier.
            %
            % See also: cv.EM/trainE, cv.EM/trainM, cv.EM/train
            %
            [logLikelihoods, labels, probs] = EM_(this.id, 'trainEM', samples);
        end

        function [logLikelihoods, labels, probs] = trainE(this, samples, means0, varargin)
            %TRAINE  Estimate the Gaussian mixture parameters from a samples set, starting from the Expectation step
            %
            %    [logLikelihoods, labels, probs] = model.trainE(samples, means0)
            %    [...] = model.trainE(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will
            %       be estimated. It should be a one-channel matrix, each row
            %       of which is a sample. If the matrix does not have `double`
            %       type it will be converted to the inner matrix of such type
            %       for the further computing.
            % * __means0__ Initial means `a_k` of mixture components. It is a
            %       one-channel matrix of `ClustersNumber-by-dims` size. If the
            %       matrix does not have `double` type it will be converted to
            %       the inner matrix of such type for the further computing.
            %
            % ## Output
            % * __logLikelihoods__ See the cv.EM.trainEM method.
            % * __labels__ See the cv.EM.trainEM method.
            % * __probs__ See the cv.EM.trainEM method.
            %
            % ## Options
            % * __Covs0__ The vector of initial covariance matrices `S_k` of
            %       mixture components. Each of covariance matrices is a
            %       one-channel matrix of `dims-by-dims` size. If the matrices
            %       do not have `double` type they will be converted to the
            %       inner matrices of such type for the further computing.
            % * __Weights0__ Initial weights `PI_k` of mixture components. It
            %       should be a one-channel floating-point vector of length
            %       `ClustersNumber`.
            %
            % This variation starts with Expectation step. You need to provide
            % initial means `a_k` of mixture components. Optionally you can
            % pass initial weights `PI_k` and covariance matrices `S_k` of
            % mixture components.
            %
            % See also: cv.EM/trainM, cv.EM/trainEM, cv.EM/train
            %
            [logLikelihoods, labels, probs] = EM_(this.id, 'trainE', samples, means0, varargin{:});
        end

        function [logLikelihoods, labels, probs] = trainM(this, samples, probs0)
            %TRAINM  Estimate the Gaussian mixture parameters from a samples set, starting from the Maximization step
            %
            %    [logLikelihoods, labels, probs] = model.trainM(samples, probs0)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will
            %       be estimated. It should be a one-channel matrix, each row
            %       of which is a sample. If the matrix does not have `double`
            %       type it will be converted to the inner matrix of such type
            %       for the further computing.
            % * __probs0__ Initial probabilities `p_{i,k}` of sample `i` to
            %       belong to mixture component `k`. It is a one-channel
            %       floating-point matrix of `nsamples-by-ClustersNumber`
            %       size.
            %
            % ## Output
            % * __logLikelihoods__ See the cv.EM.trainEM method.
            % * __labels__ See the cv.EM.trainEM method.
            % * __probs__ See the cv.EM.trainEM method.
            %
            % This variation starts with Maximization step. You need to
            % provide initial probabilities `p_{i,k}` to use this option.
            %
            % See also: cv.EM/trainE, cv.EM/trainEM, cv.EM/train
            %
            [logLikelihoods, labels, probs] = EM_(this.id, 'trainM', samples, probs0);
        end

        function [logLikelihoods, labels, probs] = predict2(this, samples)
            %PREDICT2  Returns log-likelihood values and indices of the most probable mixture component for given samples
            %
            %    [logLikelihoods, labels, probs] = model.predict2(sample)
            %
            % ## Input
            % * __samples__ Samples for classification. It should be a
            %       one-channel matrix of size `nsamples-by-dims` with each
            %       row representing one sample.
            %
            % ## Output
            % * __logLikelihoods__ Output vector that contains a
            %       likelihood logarithm value for each sample. It has
            %       `nsamples-by-1` size and `double` type.
            % * __labels__ Output "class label" for each sample:
            %       `labels_i = argmax_{k}(p_{i,k}), i=1..N` (indices of the
            %       most probable mixture component for each sample). It has
            %       `nsamples-by-1` size and `double` type.
            % * __probs__ Optional output matrix that contains posterior
            %       probabilities of each mixture component given the sample.
            %       It has `nsamples-by-ClustersNumber` size and `double`
            %       type.
            %
            % See also: cv.EM/predict
            %
            [results, probs] = EM_(this.id, 'predict2', samples);
            logLikelihoods = results(:,1);
            labels = results(:,2);
        end
    end

    %% Getters/Setters
    methods
        function value = get.ClustersNumber(this)
            value = EM_(this.id, 'get', 'ClustersNumber');
        end
        function set.ClustersNumber(this, value)
            EM_(this.id, 'set', 'ClustersNumber', value);
        end

        function value = get.CovarianceMatrixType(this)
            value = EM_(this.id, 'get', 'CovarianceMatrixType');
        end
        function set.CovarianceMatrixType(this, value)
            EM_(this.id, 'set', 'CovarianceMatrixType', value);
        end

        function value = get.TermCriteria(this)
            value = EM_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            EM_(this.id, 'set', 'TermCriteria', value);
        end
    end

end
