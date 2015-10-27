classdef GBTrees < handle
    %GBTREES  Gradient Boosted Trees
    %
    % ## Gradient Boosted Trees
    %
    % Gradient Boosted Trees (GBT) is a generalized boosting algorithm
    % introduced by [JFGBT]. In contrast to the AdaBoost.M1 algorithm, GBT can
    % deal with both multiclass classification and regression problems.
    % Moreover, it can use any differential loss function, some popular ones
    % are implemented. Decision trees (cv.DTrees) usage as base learners
    % allows to process ordered and categorical variables.
    %
    % ### Training the GBT model
    %
    % Gradient Boosted Trees model represents an ensemble of single regression
    % trees built in a greedy fashion. Training procedure is an iterative
    % process similar to the numerical optimization via the gradient descent
    % method. Summary loss on the training set depends only on the current
    % model predictions for the training samples, in other words
    % `sum_{i=1..N} L(y_i, F(x_i)) = L(F(x_1), F(x_2), ... , F(x_N)) = L(F)`.
    % And the `L(F)` gradient can be computed as follows:
    %
    %    grad(L(F)) = ( dL(y_1,F(x_1))/dF(x_1), ... , dL(y_N,F(x_N))/dF(x_N) )
    %
    % At every training step, a single regression tree is built to predict an
    % antigradient vector components. Step length is computed corresponding to
    % the loss function and separately for every region determined by the tree
    % leaf. It can be eliminated by changing values of the leaves directly.
    %
    % See below the main scheme of the training process:
    %
    % 1. Find the best constant model.
    % 2. For `i` in `[1,M]`:
    %    1. Compute the antigradient.
    %    2. Grow a regression tree to predict antigradient components.
    %    3. Change values in the tree leaves.
    %    4. Add the tree to the model.
    %
    % The following loss functions are implemented for regression problems:
    %
    % * __Squared__ Squared loss: `L(y,f(x)) = 0.5*(y-f(x))^2`
    %
    % * __Absolute__ Absolute loss: `L(y,f(x)) = |y-f(x)|`
    %
    % * __Huber__ Huber loss:
    %
    %                    { delta * (|y-f(x)| - delta/2) , |y-f(x)| > delta
    %        L(y,f(x)) = {
    %                    { 0.5 * (y-f(x))^2             , |y-f(x)| <= delta
    %
    %    where `delta` is the `alpha`-quantile estimation of the `|y-f(x)|`.
    % In the current implementation `alpha=0.2`.
    %
    % The following loss functions are implemented for classification
    % problems:
    %
    % * __Deviance__ Deviance or cross-entropy loss: `K` functions are built,
    % one function for each output class, and
    % `L(y,f_1(x),...,f_K(x)) = -sum_{k=0..K} 1(y=k) ln(p_k(x))`,
    % where `p_k(x) = exp(f_k(x)) / sum_{i=1..K} exp(f_i(x))` is the
    % estimation of the probability of `y=k`.
    %
    % As a result, you get the following model:
    %
    %    f(x) = f_0 + nu * sum_{i=1..M} T_i(x)
    %
    % where `f_0` is the initial guess (the best constant model) and `nu` is a
    % regularization parameter from the interval `(0,1]`, further called
    % *shrinkage*.
    %
    % ### Predicting with the GBT Model
    %
    % To get the GBT model prediction, you need to compute the sum of
    % responses of all the trees in the ensemble. For regression problems, it
    % is the answer. For classification problems, the result is
    % `argmax_{i=1..K}(f_i(x))`.
    %
    % ## References
    % [JFGBT]:
    % > Jerome Friedman:
    % > http://www.salfordsystems.com/doc/GreedyFuncApproxSS.pdf
    %
    % See also: cv.GBTrees.GBTrees, cv.DTrees, cv.Boost, fitensemble
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Cluster possible values of a categorical variable into
        % `K <= MaxCategories` clusters to find a suboptimal split.
        %
        % If a discrete variable, on which the training procedure tries to
        % make a split, takes more than `MaxCategories` values, the precise
        % best subset estimation may take a very long time because the
        % algorithm is exponential. Instead, many decision trees engines
        % (including our implementation) try to find sub-optimal split in this
        % case by clustering all the samples into `MaxCategories` clusters
        % that is some categories are merged together. The clustering is
        % applied only in `n > 2`-class classification problems for
        % categorical variables with `N > MaxCategories` possible values. In
        % case of regression and 2-class classification the optimal split can
        % be found efficiently without employing clustering, thus the
        % parameter is not used in these cases. Default value is 10.
        MaxCategories
        % The maximum possible depth of the tree.
        %
        % That is the training algorithms attempts to split a node while its
        % depth is less than `MaxDepth`. The root node has zero depth. The
        % actual depth may be smaller if the other termination criteria are
        % met (see the outline of the training procedure here), and/or if the
        % tree is pruned. Default value is 3.
        MaxDepth
        % If the number of samples in a node is less than this parameter then
        % the node will not be split.
        %
        % Default value is 10.
        MinSampleCount
        % If `CVFolds > 1` then algorithms prunes the built decision tree
        % using K-fold cross-validation procedure where `K` is equal to
        % `CVFolds`.
        %
        % Default value is 0.
        CVFolds
        % If true then surrogate splits will be built.
        %
        % These splits allow to work with missing data and compute variable
        % importance correctly. Default value is false.
        % **Note**: currently it's not implemented
        UseSurrogates
        % If true then a pruning will be harsher.
        %
        % This will make a tree more compact and more resistant to the
        % training data noise but a bit less accurate. Default value is false.
        Use1SERule
        % If true then pruned branches are physically removed from the tree.
        %
        % Otherwise they are retained and it is possible to get results from
        % the original unpruned (or pruned less aggressively) tree. Default
        % value is false.
        TruncatePrunedTree
        % Termination criteria for regression trees.
        %
        % If all absolute differences between an estimated value in a node and
        % values of train samples in this node are less than this parameter
        % then the node will not be split further. Default value is 0
        RegressionAccuracy
        % The array of a priori class probabilities, sorted by the class label
        % value.
        %
        % The parameter can be used to tune the decision tree preferences
        % toward a certain class. For example, if you want to detect some rare
        % anomaly occurrence, the training base will likely contain much more
        % normal cases than anomalies, so a very good classification
        % performance will be achieved just by considering every case as
        % normal. To avoid this, the priors can be specified, where the
        % anomaly probability is artificially increased (up to 0.5 or even
        % greater), so the weight of the misclassified anomalies becomes much
        % bigger, and the tree is adjusted properly.
        %
        % You can also think about this parameter as weights of prediction
        % categories which determine relative weights that you give to
        % misclassification. That is, if the weight of the first category is 1
        % and the weight of the second category is 10, then each mistake in
        % predicting the second category is equivalent to making 10 mistakes
        % in predicting the first category. Default value is empty matrix.
        Priors

        % Count of boosting algorithm iterations.
        %
        % `WeakCount*K` is the total count of trees in the GBT model, where
        % `K` is the output classes count (equal to one in case of a
        % regression). Default 200
        WeakCount
        % Type of the loss function used for training.
        %
        % See Training the GBT model. It must be one of the following types:
        %
        % * __Squared__ (default) for regression problems.
        % * __Absolute__ for regression problems.
        % * __Huber__ for regression problems.
        % * __Deviance__ for classification problems.
        %
        % The first three types are used for regression problems, and the last
        % one for classification.
        LossFunctionType
        % Portion of the whole training set used for each algorithm iteration.
        %
        % Subset is generated randomly. For more information see [JFGBT].
        % Default 0.8
        SubsamplePortion
        % Regularization parameter.
        %
        % See Training the GBT model. Default 0.01
        Shrinkage
    end

    %% Constructor/destructor
    methods
        function this = GBTrees(varargin)
            %GBTREES  Creates/trains a new GBTrees model
            %
            %    model = cv.GBTrees
            %    model = cv.GBTrees(...)
            %
            % The first variant creates an empty model. Use cv.GBTrees.train
            % to train the model, or cv.GBTrees.load to load a pre-trained
            % model.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.GBTrees, cv.GBTrees.train
            %
            this.id = GBTrees_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.GBTrees
            %
            GBTrees_(this.id, 'delete');
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
            % See also: cv.GBTrees.empty, cv.GBTrees.load
            %
            GBTrees_(this.id, 'clear');
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
            % See also: cv.GBTrees.clear, cv.GBTrees.load
            %
            b = GBTrees_(this.id, 'empty');
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
            % See also: cv.GBTrees.load
            %
            [varargout{1:nargout}] = GBTrees_(this.id, 'save', filename);
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
            % See also: cv.GBTrees.save
            %
            GBTrees_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.GBTrees.save, cv.GBTrees.load
            %
            name = GBTrees_(this.id, 'getDefaultName');
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
            % See also: cv.GBTrees.train
            %
            count = GBTrees_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.GBTrees.empty, cv.GBTrees.train
            %
            b = GBTrees_(this.id, 'isTrained');
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
            % If `LossFunctionType='Deviance'` the problem is classification,
            % and regression otherwise.
            %
            % See also: cv.GBTrees.isTrained
            %
            b = GBTrees_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains a Gradient boosted tree model
            %
            %    status = model.train(samples, responses)
            %    status = model.train(csvFilename, [])
            %    [...] = model.train(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Row vectors of feature.
            % * __responses__ Output of the corresponding feature vectors.
            % * __csvFilename__ The input CSV file name from which to load
            %       dataset. In this variant, you should set the second
            %       argument to an empty array.
            %
            % ## Output
            % * __status__ Success flag.
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
            % The method trains the cv.GBTrees model.
            %
            % The train method follows the common template. Both layouts
            % ('Row' and 'Col') are supported. `samples` must be of `single`
            % type. `responses` must be a matrix of type `int32` or `single`.
            % In both cases it is converted into `single` matrix inside the
            % training procedure. `VarIdx` and `SampleIdx` must be a list of
            % indices (`int32`) or a mask (`uint8`, `int8`, or `logical`).
            %
            % See also: cv.GBTrees.predict, cv.GBTrees.calcError
            %
            status = GBTrees_(this.id, 'train', samples, responses, varargin{:});
        end

        function [err,resp] = calcError(this, samples, responses, varargin)
            %CALCERROR  Computes error on the training or test dataset
            %
            %    err = model.calcError(samples, responses)
            %    err = model.calcError(csvFilename, [])
            %    [err,resp] = model.calcError(...)
            %    [...] = model.calcError(..., 'OptionName', optionValue, ...)
            %
            % ## Inputs
            % * __samples__ See the train method.
            % * __responses__ See the train method.
            % * __csvFilename__ See the train method.
            %
            % ## Outputs
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
            % See also: cv.GBTrees.train, cv.GBTrees.predict
            %
            [err,resp] = GBTrees_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts response(s) for the provided sample(s)
            %
            %    [results,f] = model.predict(samples)
            %    [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Input row vectors (one or more) stored as rows of
            %       a floating-point matrix. If not all the variables were
            %       actually used during training, `samples` contains forged
            %       values at the appropriate places.
            %
            % ## Output
            % * __results__ Output labels or regression values.
            % * __f__ The same as the response of the first sample.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent.
            %       Not used. default 0
            %
            % The method predicts the response corresponding to the given
            % sample. The result is either the class label or the estimated
            % function value. The method enables using the parallel version of
            % the GBT model prediction if the OpenCV is built with the TBB
            % library. In this case, predictions of single trees are computed in
            % a parallel fashion.
            %
            % See also: cv.GBTrees.train, cv.GBTrees.calcError
            %
            [results,f] = GBTrees_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% GBTrees
    methods
        function setK(this, K)
            %SETK  Set number of tree ensembles built in case of the classification problem
            %
            %    model.setK(K)
            %
            % ## Input
            % * __K__ Use this parameter to change the output to sum of the
            %       trees' predictions in the k-th ensemble only. To get the
            %       total GBT model prediction, `K` value must be -1. For
            %       regression problems, `K` is also equal to -1. Its value is
            %       -1 by default.
            %
            % See Training the GBT model.
            %
            % See also: cv.GBTrees.predict
            %
            GBTrees_(this.id, 'setK', K);
        end

        function roots = getRoots(this)
            %GETROOS  Returns indices of root nodes
            %
            %    roots = classifier.getRoots()
            %
            % ## Output
            % * __roots__ vector of indices.
            %
            % See also: cv.GBTrees.getNodes
            %
            roots = GBTrees_(this.id, 'getRoots');
        end

        function nodes = getNodes(this)
            %GETNODES  Returns all the nodes
            %
            %    nodes = classifier.getNodes()
            %
            % ## Output
            % * __nodes__ Struct-array with the following fields:
            %       * __value__ Value at the node: a class label in case of
            %             classification or estimated function value in case
            %             of regression.
            %       * __classIdx__ Class index normalized to `0..class_count-1`
            %             range and assigned to the node. It is used
            %             internally in classification trees and tree
            %             ensembles.
            %       * __parent__ Index of the parent node.
            %       * __left__ Index of the left child node.
            %       * __right__ Index of right child node.
            %       * __defaultDir__ Default direction where to go (-1: left
            %             or +1: right). It helps in the case of missing
            %             values.
            %       * __split__ Index of the first split.
            %
            % all the node indices are zero-based indices in the returned
            % vector.
            %
            % See also: cv.GBTrees.getRoots
            %
            nodes = GBTrees_(this.id, 'getNodes');
        end

        function splits = getSplits(this)
            %GETSPLITS  Returns all the splits
            %
            %    splits = classifier.getSplits()
            %
            % ## Output
            % * __splits__ Struct-array with the following fields:
            %       * __varIdx__ Index of variable on which the split is
            %             created.
            %       * __inversed__ If true, then the inverse split rule is
            %             used (i.e. left and right branches are exchanged in
            %             the rule expressions below).
            %       * __quality__ The split quality, a positive number. It is
            %             used to choose the best split. (It is also used to
            %             compute variable importance).
            %       * __next__ Index of the next split in the list of splits
            %             for the node (surrogate splits).
            %       * __c__ The threshold value in case of split on an ordered
            %             variable. The rule is:
            %             `if var_value < c, next_node = left; else next_node = right; end`
            %       * __subsetOfs__ Offset of the bitset used by the split on
            %             a categorical variable. The rule is:
            %             `if bitset(var_value) == 1, next_node = left; else next_node = right; end`
            %
            % all the split indices are zero-based indices in the returned
            % vector.
            %
            % See also: cv.GBTrees.getSubsets, cv.GBTrees.getNodes
            %
            splits = GBTrees_(this.id, 'getSplits');
        end

        function subsets = getSubsets(this)
            %GETSUBSETS  Returns all the bitsets for categorical splits
            %
            %    subsets = classifier.getSubsets()
            %
            % ## Output
            % * __subsets__ vector of indices.
            %
            % `splits(i).subsetOfs` is an offset in the returned vector.
            %
            % See also: cv.GBTrees.getSplits
            %
            subsets = GBTrees_(this.id, 'getSubsets');
        end
    end

    %% Getters/Setters
    methods
        function value = get.CVFolds(this)
            value = GBTrees_(this.id, 'get', 'CVFolds');
        end
        function set.CVFolds(this, value)
            GBTrees_(this.id, 'set', 'CVFolds', value);
        end

        function value = get.MaxCategories(this)
            value = GBTrees_(this.id, 'get', 'MaxCategories');
        end
        function set.MaxCategories(this, value)
            GBTrees_(this.id, 'set', 'MaxCategories', value);
        end

        function value = get.MaxDepth(this)
            value = GBTrees_(this.id, 'get', 'MaxDepth');
        end
        function set.MaxDepth(this, value)
            GBTrees_(this.id, 'set', 'MaxDepth', value);
        end

        function value = get.MinSampleCount(this)
            value = GBTrees_(this.id, 'get', 'MinSampleCount');
        end
        function set.MinSampleCount(this, value)
            GBTrees_(this.id, 'set', 'MinSampleCount', value);
        end

        function value = get.Priors(this)
            value = GBTrees_(this.id, 'get', 'Priors');
        end
        function set.Priors(this, value)
            GBTrees_(this.id, 'set', 'Priors', value);
        end

        function value = get.RegressionAccuracy(this)
            value = GBTrees_(this.id, 'get', 'RegressionAccuracy');
        end
        function set.RegressionAccuracy(this, value)
            GBTrees_(this.id, 'set', 'RegressionAccuracy', value);
        end

        function value = get.TruncatePrunedTree(this)
            value = GBTrees_(this.id, 'get', 'TruncatePrunedTree');
        end
        function set.TruncatePrunedTree(this, value)
            GBTrees_(this.id, 'set', 'TruncatePrunedTree', value);
        end

        function value = get.Use1SERule(this)
            value = GBTrees_(this.id, 'get', 'Use1SERule');
        end
        function set.Use1SERule(this, value)
            GBTrees_(this.id, 'set', 'Use1SERule', value);
        end

        function value = get.UseSurrogates(this)
            value = GBTrees_(this.id, 'get', 'UseSurrogates');
        end
        function set.UseSurrogates(this, value)
            GBTrees_(this.id, 'set', 'UseSurrogates', value);
        end

        function value = get.WeakCount(this)
            value = GBTrees_(this.id, 'get', 'WeakCount');
        end
        function set.WeakCount(this, value)
            GBTrees_(this.id, 'set', 'WeakCount', value);
        end

        function value = get.LossFunctionType(this)
            value = GBTrees_(this.id, 'get', 'LossFunctionType');
        end
        function set.LossFunctionType(this, value)
            GBTrees_(this.id, 'set', 'LossFunctionType', value);
        end

        function value = get.SubsamplePortion(this)
            value = GBTrees_(this.id, 'get', 'SubsamplePortion');
        end
        function set.SubsamplePortion(this, value)
            GBTrees_(this.id, 'set', 'SubsamplePortion', value);
        end

        function value = get.Shrinkage(this)
            value = GBTrees_(this.id, 'get', 'Shrinkage');
        end
        function set.Shrinkage(this, value)
            GBTrees_(this.id, 'set', 'Shrinkage', value);
        end
    end

end
