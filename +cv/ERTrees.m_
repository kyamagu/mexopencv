classdef ERTrees < handle
    %ERTREES  Extremely randomized trees
    %
    % ## Extremely randomized trees
    %
    % Extremely randomized trees have been introduced by [ERT06].
    % The algorithm of growing Extremely randomized trees is similar to Random
    % Trees (Random Forest), but there are two differences:
    %
    % 1. Extremely randomized trees don't apply the bagging procedure to
    %    constract the training samples for each tree. The same input training
    %    set is used to train all trees.
    % 2. Extremely randomized trees pick a node split very extremely (both a
    %    variable index and variable spliting value are chosen randomly),
    %    whereas Random Forest finds the best split (optimal one by variable
    %    index and variable spliting value) among random subset of variables.
    %
    % ## References
    % [ERT06]:
    % > Pierre Geurts, Damien Ernst and Louis Wehenkel.
    % > "Extremely randomized trees", 2006
    % > http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.65.7485&rep=rep1&type=pdf
    %
    % See also: cv.ERTrees.ERTrees, cv.RTrees, cv.DTrees, cv.Boost, fitensemble
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
        % A low value will likely underfit and conversely a high value will
        % likely overfit. The optimal value can be obtained using cross
        % validation or other suitable methods.
        %
        % That is the training algorithms attempts to split a node while its
        % depth is less than `MaxDepth`. The root node has zero depth. The
        % actual depth may be smaller if the other termination criteria are
        % met (see the outline of the training procedure here), and/or if the
        % tree is pruned. Default value is 5.
        MaxDepth
        % If the number of samples in a node is less than this parameter then
        % the node will not be split.
        %
        % It is the minimum number of samples required at a leaf node for it
        % to be split. A reasonable value is a small percentage of the total
        % data e.g. 1%.
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
        % then the node will not be split further. Default value is 0.0
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

        % Whether to compute variables importance.
        %
        % If true then variable importance will be calculated and then it can
        % be retrieved by cv.ERTrees.getVarImportance. Default value is false.
        CalculateVarImportance
        % The size of the randomly selected subset of features at each tree
        % node and that are used to find the best split(s).
        %
        % If you set it to 0 then the size will be set to the square root of
        % the total number of features. Default value is 0.
        ActiveVarCount
        % The termination criteria that specifies when the training algorithm
        % stops.
        %
        % Either when the specified number of trees is trained and added to
        % the ensemble or when sufficient accuracy (measured as OOB error) is
        % achieved. Typically the more trees you have the better the accuracy.
        % However, the improvement in accuracy generally diminishes and
        % asymptotes pass a certain number of trees. Also to keep in mind, the
        % number of tree increases the prediction time linearly. Default value
        % is `struct('type','Count+EPS', 'maxCount',50, 'epsilon',0.1)`
        TermCriteria
    end

    %% Constructor/destructor
    methods
        function this = ERTrees(varargin)
            %ERTREES  Creates/trains a new Extremely Random Trees model
            %
            %    model = cv.ERTrees()
            %    model = cv.ERTrees(...)
            %
            % The first variant creates an empty model. Use cv.ERTrees.train
            % to train the model, or cv.ERTrees.load to load a pre-trained
            % model.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.ERTrees, cv.ERTrees.train
            %
            this.id = ERTrees_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.ERTrees
            %
            ERTrees_(this.id, 'delete');
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
            % See also: cv.ERTrees.empty, cv.ERTrees.load
            %
            ERTrees_(this.id, 'clear');
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
            % See also: cv.ERTrees.clear, cv.ERTrees.load
            %
            b = ERTrees_(this.id, 'empty');
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
            % See also: cv.ERTrees.load
            %
            [varargout{1:nargout}] = ERTrees_(this.id, 'save', filename);
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
            % See also: cv.ERTrees.save
            %
            ERTrees_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.ERTrees.save, cv.ERTrees.load
            %
            name = ERTrees_(this.id, 'getDefaultName');
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
            % See also: cv.ERTrees.train
            %
            count = ERTrees_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.ERTrees.empty, cv.ERTrees.train
            %
            b = ERTrees_(this.id, 'isTrained');
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
            % See also: cv.ERTrees.isTrained
            %
            b = ERTrees_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains the Extremely Random Trees model
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
            % * __Flags__ The optional training flags, model-dependent. For
            %       convenience, you can set the individual flag options
            %       below, instead of directly setting bits here. default 0
            % * __RawOutput__ See the predict method. default false
            % * __PredictSum__ See the predict method. default false
            % * __PredictMaxVote__ See the predict method. default false
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
            % The method trains the cv.ERTrees model.
            %
            % The method is very similar to the method cv.DTrees.train and
            % follows the generic method train conventions. The estimate of
            % the training error (OOB-error) is stored inside the class (see
            % cv.ERTrees.getVarImportance).
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.ERTrees.predict, cv.ERTrees.calcError
            %
            status = ERTrees_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.ERTrees.train, cv.ERTrees.predict
            %
            [err,resp] = ERTrees_(this.id, 'calcError', samples, responses, varargin{:});
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
            % This method returns the cumulative result from all the trees in
            % the forest (the class that receives the majority of voices, or
            % the mean of the regression function estimates).
            %
            % See also: cv.ERTrees.train, cv.ERTrees.calcError
            %
            [results,f] = ERTrees_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% ERTrees
    methods
        function v = getVarImportance(this)
            %GETVARIMPORTANCE  Returns the variable importance array
            %
            %    v = classifier.getVarImportance()
            %
            % ## Output
            % * __v__ the variable importance vector, computed at the training
            %       stage when `CalculateVarImportance` is set to true. If
            %       this flag was set to false, the empty matrix is returned.
            %
            % See also: cv.ERTrees.CalculateVarImportance
            %
            v = ERTrees_(this.id, 'getVarImportance');
        end

        function roots = getRoots(this)
            %GETROOS  Returns indices of root nodes
            %
            %    roots = classifier.getRoots()
            %
            % ## Output
            % * __roots__ vector of indices.
            %
            % See also: cv.ERTrees.getNodes
            %
            roots = ERTrees_(this.id, 'getRoots');
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
            % See also: cv.ERTrees.getRoots
            %
            nodes = ERTrees_(this.id, 'getNodes');
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
            % See also: cv.ERTrees.getSubsets, cv.ERTrees.getNodes
            %
            splits = ERTrees_(this.id, 'getSplits');
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
            % See also: cv.ERTrees.getSplits
            %
            subsets = ERTrees_(this.id, 'getSubsets');
        end
    end

    %% Getters/Setters
    methods
        function value = get.CVFolds(this)
            value = ERTrees_(this.id, 'get', 'CVFolds');
        end
        function set.CVFolds(this, value)
            ERTrees_(this.id, 'set', 'CVFolds', value);
        end

        function value = get.MaxCategories(this)
            value = ERTrees_(this.id, 'get', 'MaxCategories');
        end
        function set.MaxCategories(this, value)
            ERTrees_(this.id, 'set', 'MaxCategories', value);
        end

        function value = get.MaxDepth(this)
            value = ERTrees_(this.id, 'get', 'MaxDepth');
        end
        function set.MaxDepth(this, value)
            ERTrees_(this.id, 'set', 'MaxDepth', value);
        end

        function value = get.MinSampleCount(this)
            value = ERTrees_(this.id, 'get', 'MinSampleCount');
        end
        function set.MinSampleCount(this, value)
            ERTrees_(this.id, 'set', 'MinSampleCount', value);
        end

        function value = get.Priors(this)
            value = ERTrees_(this.id, 'get', 'Priors');
        end
        function set.Priors(this, value)
            ERTrees_(this.id, 'set', 'Priors', value);
        end

        function value = get.RegressionAccuracy(this)
            value = ERTrees_(this.id, 'get', 'RegressionAccuracy');
        end
        function set.RegressionAccuracy(this, value)
            ERTrees_(this.id, 'set', 'RegressionAccuracy', value);
        end

        function value = get.TruncatePrunedTree(this)
            value = ERTrees_(this.id, 'get', 'TruncatePrunedTree');
        end
        function set.TruncatePrunedTree(this, value)
            ERTrees_(this.id, 'set', 'TruncatePrunedTree', value);
        end

        function value = get.Use1SERule(this)
            value = ERTrees_(this.id, 'get', 'Use1SERule');
        end
        function set.Use1SERule(this, value)
            ERTrees_(this.id, 'set', 'Use1SERule', value);
        end

        function value = get.UseSurrogates(this)
            value = ERTrees_(this.id, 'get', 'UseSurrogates');
        end
        function set.UseSurrogates(this, value)
            ERTrees_(this.id, 'set', 'UseSurrogates', value);
        end

        function value = get.ActiveVarCount(this)
            value = ERTrees_(this.id, 'get', 'ActiveVarCount');
        end
        function set.ActiveVarCount(this, value)
            ERTrees_(this.id, 'set', 'ActiveVarCount', value);
        end

        function value = get.CalculateVarImportance(this)
            value = ERTrees_(this.id, 'get', 'CalculateVarImportance');
        end
        function set.CalculateVarImportance(this, value)
            ERTrees_(this.id, 'set', 'CalculateVarImportance', value);
        end

        function value = get.TermCriteria(this)
            value = ERTrees_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            ERTrees_(this.id, 'set', 'TermCriteria', value);
        end
    end

end
