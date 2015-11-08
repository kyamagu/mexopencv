classdef DTrees < handle
    %DTREES  Decision Trees
    %
    % The class represents a single decision tree or a collection of decision
    % trees.
    %
    % The current public interface of the class allows user to train only a
    % single decision tree, however the class is capable of storing multiple
    % decision trees and using them for prediction (by summing responses or
    % using a voting schemes), and the derived from cv.DTrees classes (such as
    % cv.RTrees and cv.Boost) use this capability to implement decision tree
    % ensembles.
    %
    % ## Decision Trees
    %
    % The ML classes discussed in this section implement Classification and
    % Regression Tree algorithms described in [Breiman84].
    %
    % The class cv.DTrees represents a single decision tree or a collection of
    % decision trees. It's also a base class for cv.RTrees and cv.Boost.
    %
    % A decision tree is a binary tree (tree where each non-leaf node has two
    % child nodes). It can be used either for classification or for regression.
    % For classification, each tree leaf is marked with a class label;
    % multiple leaves may have the same label. For regression, a constant is
    % also assigned to each tree leaf, so the approximation function is
    % piecewise constant.
    %
    % ### Predicting with Decision Trees
    %
    % To reach a leaf node and to obtain a response for the input feature
    % vector, the prediction procedure starts with the root node. From each
    % non-leaf node the procedure goes to the left (selects the left child
    % node as the next observed node) or to the right based on the value of a
    % certain variable whose index is stored in the observed node. The
    % following variables are possible:
    %
    % * **Ordered variables**. The variable value is compared with a threshold
    % that is also stored in the node. If the value is less than the
    % threshold, the procedure goes to the left. Otherwise, it goes to the
    % right. For example, if the weight is less than 1 kilogram, the procedure
    % goes to the left, else to the right.
    %
    % * **Categorical variables**. A discrete variable value is tested to see
    % whether it belongs to a certain subset of values (also stored in the
    % node) from a limited set of values the variable could take. If it does,
    % the procedure goes to the left. Otherwise, it goes to the right. For
    % example, if the color is green or red, go to the left, else to the
    % right.
    %
    % So, in each node, a pair of entities (`variable_index`,
    % `decision_rule (threshold/subset)`) is used. This pair is called a split
    % (split on the variable `variable_index`). Once a leaf node is reached,
    % the value assigned to this node is used as the output of the prediction
    % procedure.
    %
    % Sometimes, certain features of the input vector are missed (for example,
    % in the darkness it is difficult to determine the object color), and the
    % prediction procedure may get stuck in the certain node (in the mentioned
    % example, if the node is split by color). To avoid such situations,
    % decision trees use so-called surrogate splits. That is, in addition to
    % the best "primary" split, every tree node may also be split to one or
    % more other variables with nearly the same results.
    %
    % ### Training Decision Trees
    %
    % The tree is built recursively, starting from the root node. All training
    % data (feature vectors and responses) is used to split the root node. In
    % each node the optimum decision rule (the best "primary" split) is found
    % based on some criteria. In machine learning, gini "purity" criteria are
    % used for classification, and sum of squared errors is used for
    % regression. Then, if necessary, the surrogate splits are found. They
    % resemble the results of the primary split on the training data. All the
    % data is divided using the primary and the surrogate splits (like it is
    % done in the prediction procedure) between the left and the right child
    % node. Then, the procedure recursively splits both left and right nodes.
    % At each node the recursive procedure may stop (that is, stop splitting
    % the node further) in one of the following cases:
    %
    % * Depth of the constructed tree branch has reached the specified maximum
    %   value.
    % * Number of training samples in the node is less than the specified
    %   threshold when it is not statistically representative to split the
    %   node further.
    % * All the samples in the node belong to the same class or, in case of
    %   regression, the variation is too small.
    % * The best found split does not give any noticeable improvement compared
    %   to a random choice.
    %
    % When the tree is built, it may be pruned using a cross-validation
    % procedure, if necessary. That is, some branches of the tree that may
    % lead to the model overfitting are cut off. Normally, this procedure is
    % only applied to standalone decision trees. Usually tree ensembles build
    % trees that are small enough and use their own protection schemes against
    % overfitting.
    %
    % ### Variable Importance
    %
    % Besides the prediction that is an obvious use of decision trees, the
    % tree can be also used for various data analyses. One of the key
    % properties of the constructed decision tree algorithms is an ability to
    % compute the importance (relative decisive power) of each variable. For
    % example, in a spam filter that uses a set of words occurred in the
    % message as a feature vector, the variable importance rating can be used
    % to determine the most "spam-indicating" words and thus help keep the
    % dictionary size reasonable.
    %
    % Importance of each variable is computed over all the splits on this
    % variable in the tree, primary and surrogate ones. Thus, to compute
    % variable importance correctly, the surrogate splits must be enabled in
    % the training parameters, even if there is no missing data.
    %
    % ## References
    % [Breiman84]:
    % > Leo Breiman, Jerome Friedman, Charles J Stone, and Richard A Olshen.
    % > "Classification and regression trees". CRC press, 1984.
    %
    % See also: cv.DTrees.DTrees, cv.RTrees, cv.Boost, fitctree, fitrtree
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
        % tree is pruned. Default value is `intmax`.
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
        % Default value is 10.
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
        % training data noise but a bit less accurate. Default value is true.
        Use1SERule
        % If true then pruned branches are physically removed from the tree.
        %
        % Otherwise they are retained and it is possible to get results from
        % the original unpruned (or pruned less aggressively) tree. Default
        % value is true.
        TruncatePrunedTree
        % Termination criteria for regression trees.
        %
        % If all absolute differences between an estimated value in a node and
        % values of train samples in this node are less than this parameter
        % then the node will not be split further. Default value is 0.01
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
    end

    %% Constructor/destructor
    methods
        function this = DTrees(varargin)
            %DTREES  Creates/trains a new decision tree model
            %
            %    model = cv.DTrees()
            %    model = cv.DTrees(...)
            %
            % The first variant creates an empty decision tree with the
            % default parameters. It should be then trained using the train
            % method (see cv.DTrees.train). Alternatively, you can load the
            % model from file using `cv.DTrees.load(filename)`.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.DTrees, cv.DTrees.train
            %
            this.id = DTrees_(0, 'new');
            % --
            %TODO: https://github.com/Itseez/opencv/issues/5070
            this.MaxDepth = 10;  % avoid std::length_error exception!
            this.CVFolds = 0;    % avoid segfault in train
            % --
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.DTrees
            %
            DTrees_(this.id, 'delete');
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
            % See also: cv.DTrees.empty, cv.DTrees.load
            %
            DTrees_(this.id, 'clear');
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
            % See also: cv.DTrees.clear, cv.DTrees.load
            %
            b = DTrees_(this.id, 'empty');
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
            % See also: cv.DTrees.load
            %
            [varargout{1:nargout}] = DTrees_(this.id, 'save', filename);
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
            % See also: cv.DTrees.save
            %
            DTrees_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.DTrees.save, cv.DTrees.load
            %
            name = DTrees_(this.id, 'getDefaultName');
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
            % See also: cv.DTrees.train
            %
            count = DTrees_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.DTrees.empty, cv.DTrees.train
            %
            b = DTrees_(this.id, 'isTrained');
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
            % See also: cv.DTrees.isTrained
            %
            b = DTrees_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains a decision tree
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
            % The method trains the cv.DTrees model.
            %
            % The method follow the generic train conventions. Both data
            % layouts ('Row' and 'Col') are supported, as well as sample and
            % variable subsets, missing measurements, arbitrary combinations
            % of input and output variable types, and so on.
            %
            % Depending on the `responses` data type (or the specified
            % `VarType` for the response), the method solves a classification
            % problem for categorical labels, otherwise the training is
            % treated as a regression problem for numerical responses.
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.DTrees.predict, cv.DTrees.calcError
            %
            status = DTrees_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.DTrees.train, cv.DTrees.predict
            %
            [err,resp] = DTrees_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts response(s) for the provided sample(s)
            %
            %    [results,f] = model.predict(samples)
            %    [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Input row vectors (one or more) stored as rows of
            %       a floating-point matrix.
            %
            % ## Output
            % * __results__ Output labels or regression values.
            % * __f__ The same as the response of the first sample.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent. For
            %       convenience, you can set the individual flag options
            %       below, instead of directly setting bits here. default 0
            % * __RawOutput__ makes the method return the raw results (the
            %       sum), not the class label. default false
            % * __CompressedInput__ compressed data, containing only the
            %       active samples/variables. default false
            % * __PreprocessedInput__ This parameter is normally set to false,
            %       implying a regular input. If it is true, the method
            %       assumes that all the values of the discrete input
            %       variables have been already normalized to 0..NCategories
            %       ranges since the decision tree uses such normalized
            %       representation internally. It is useful for faster
            %       prediction with tree ensembles. For ordered input
            %       variables, the flag is not used. Default false
            % * __PredictAuto__ Setting this to true, overrides all of the
            %       other `Predict*` flags. It automatically chooses between
            %       `PredictSum` and `PredictMaxVote` (if the model is a
            %       regressor or the number of classes are 2 with `RawOutput`
            %       set then it picks `PredictSum`, otherwise it picks
            %       `PredictMaxVote` by default). default true
            % * __PredictSum__ If true then return sum of votes instead of the
            %         class label. default false
            % * __PredictMaxVote__ If true then return the class label with
            %       the max vote. default false
            %
            % The method traverses the decision tree and returns rhe
            % prediction result from the reached leaf node, either the class
            % label or the estimated function value.
            %
            % See also: cv.DTrees.train, cv.DTrees.calcError
            %
            [results,f] = DTrees_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% DTrees
    methods
        function roots = getRoots(this)
            %GETROOS  Returns indices of root nodes
            %
            %    roots = classifier.getRoots()
            %
            % ## Output
            % * __roots__ vector of indices.
            %
            % See also: cv.DTrees.getNodes
            %
            roots = DTrees_(this.id, 'getRoots');
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
            % See also: cv.DTrees.getRoots
            %
            nodes = DTrees_(this.id, 'getNodes');
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
            % See also: cv.DTrees.getSubsets, cv.DTrees.getNodes
            %
            splits = DTrees_(this.id, 'getSplits');
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
            % See also: cv.DTrees.getSplits
            %
            subsets = DTrees_(this.id, 'getSubsets');
        end
    end

    %% Getters/Setters
    methods
        function value = get.CVFolds(this)
            value = DTrees_(this.id, 'get', 'CVFolds');
        end
        function set.CVFolds(this, value)
            DTrees_(this.id, 'set', 'CVFolds', value);
        end

        function value = get.MaxCategories(this)
            value = DTrees_(this.id, 'get', 'MaxCategories');
        end
        function set.MaxCategories(this, value)
            DTrees_(this.id, 'set', 'MaxCategories', value);
        end

        function value = get.MaxDepth(this)
            value = DTrees_(this.id, 'get', 'MaxDepth');
        end
        function set.MaxDepth(this, value)
            DTrees_(this.id, 'set', 'MaxDepth', value);
        end

        function value = get.MinSampleCount(this)
            value = DTrees_(this.id, 'get', 'MinSampleCount');
        end
        function set.MinSampleCount(this, value)
            DTrees_(this.id, 'set', 'MinSampleCount', value);
        end

        function value = get.Priors(this)
            value = DTrees_(this.id, 'get', 'Priors');
        end
        function set.Priors(this, value)
            DTrees_(this.id, 'set', 'Priors', value);
        end

        function value = get.RegressionAccuracy(this)
            value = DTrees_(this.id, 'get', 'RegressionAccuracy');
        end
        function set.RegressionAccuracy(this, value)
            DTrees_(this.id, 'set', 'RegressionAccuracy', value);
        end

        function value = get.TruncatePrunedTree(this)
            value = DTrees_(this.id, 'get', 'TruncatePrunedTree');
        end
        function set.TruncatePrunedTree(this, value)
            DTrees_(this.id, 'set', 'TruncatePrunedTree', value);
        end

        function value = get.Use1SERule(this)
            value = DTrees_(this.id, 'get', 'Use1SERule');
        end
        function set.Use1SERule(this, value)
            DTrees_(this.id, 'set', 'Use1SERule', value);
        end

        function value = get.UseSurrogates(this)
            value = DTrees_(this.id, 'get', 'UseSurrogates');
        end
        function set.UseSurrogates(this, value)
            DTrees_(this.id, 'set', 'UseSurrogates', value);
        end
    end

end
