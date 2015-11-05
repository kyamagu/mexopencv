classdef Boost < handle
    %BOOST  Boosting
    %
    % Boosted tree classifier derived from cv.DTrees.
    %
    % ## Boosting
    %
    % A common machine learning task is supervised learning. In supervised
    % learning, the goal is to learn the functional relationship `F: y = F(x)`
    % between the input `x` and the output `y`. Predicting the qualitative
    % output is called *classification*, while predicting the quantitative
    % output is called *regression*.
    %
    % Boosting is a powerful learning concept that provides a solution to the
    % supervised classification learning task. It combines the performance of
    % many weak classifiers to produce a powerful committee [HTF01]. A weak
    % classifier is only required to be better than chance, and thus can be
    % very simple and computationally inexpensive. However, many of them
    % smartly combine results to a strong classifier that often outperforms
    % most monolithic strong classifiers such as SVMs and Neural Networks.
    %
    % Decision trees are the most popular weak classifiers used in boosting
    % schemes. Often the simplest decision trees with only a single split node
    % per tree (called stumps) are sufficient.
    %
    % The boosted model is based on `N` training examples `(xi,yi), i=1..N`
    % with `xi IN R^k` and `yi IN {-1,+1}`. `xi` is a K-component vector. Each
    % component encodes a feature relevant to the learning task at hand. The
    % desired two-class output is encoded as -1 and +1.
    %
    % Different variants of boosting are known as Discrete Adaboost, Real
    % AdaBoost, LogitBoost, and Gentle AdaBoost [FHT98]. All of them are very
    % similar in their overall structure. Therefore, this chapter focuses only
    % on the standard two-class Discrete AdaBoost algorithm, outlined below.
    % Initially the same weight is assigned to each sample (step 2). Then, a
    % weak classifier `f_m(x)` is trained on the weighted training data
    % (step 3a). Its weighted training error and scaling factor `c_m` is
    % computed (step 3b). The weights are increased for training samples that
    % have been misclassified (step 3c). All weights are then normalized, and
    % the process of finding the next weak classifier continues for another
    % `M-1` times. The final classifier `F(x)` is the sign of the weighted sum
    % over the individual weak classifiers (step 4).
    %
    % ### Two-class Discrete AdaBoost Algorithm
    %
    % 1. Set `N` examples `(xi,yi), i=1..N` with `xi IN R^K`, `yi IN {-1,+1}`.
    % 2. Assign weights as `wi = 1/N, i=1..N`.
    % 3. Repeat for `m=1,2,...,M`:
    %    1. Fit the classifier `f_m(x) IN {-1,1}`, using weights `wi` on the
    %       training data.
    %    2. Compute `err_m = Ew[1_(y!=f_m(x))]`, `c_m = log((1-err_m)/err_m)`.
    %    3. Set `wi = wi * exp[c_m * 1(yi!=f_m(xi))], i=1,2,...,N`, and
    %       renormalize so that `sum_i{wi}=1`.
    % 4. Classify new samples `x` using the formula:
    %    `sign(sum{m} = 1 * M * c_m * f_m(x))`.
    %
    % **Note**: Similar to the classical boosting methods, the current
    % implementation supports two-class classifiers only. For `M > 2` classes,
    % there is the AdaBoost.MH algorithm (described in [FHT98]) that reduces
    % the problem to the two-class problem, yet with a much larger training
    % set.
    %
    % To reduce computation time for boosted models without substantially
    % losing accuracy, the influence trimming technique can be employed. As
    % the training algorithm proceeds and the number of trees in the ensemble
    % is increased, a larger number of the training samples are classified
    % correctly and with increasing confidence, thereby those samples receive
    % smaller weights on the subsequent iterations. Examples with a very low
    % relative weight have a small impact on the weak classifier training.
    % Thus, such examples may be excluded during the weak classifier training
    % without having much effect on the induced classifier. This process is
    % controlled with the `WeightTrimRate` parameter. Only examples with the
    % summary fraction `WeightTrimRate` of the total weight mass are used in
    % the weak classifier training. Note that the weights for all training
    % examples are recomputed at each training iteration. Examples deleted at
    % a particular iteration may be used again for learning some of the weak
    % classifiers further [FHT98].
    %
    % ###  Prediction with Boost
    %
    % The cv.Boost.predict method should be used. Pass `RawOutput=true` to get
    % the raw sum from Boost classifier.
    %
    % ## References
    % [HTF01]:
    % > Hastie Trevor, Tibshirani Robert, and Friedman Jerome. "The elements
    % > of statistical learning: data mining, inference and prediction".
    % > New York: Springer-Verlag, 1(8):371-406, 2001.
    %
    % [FHT98]:
    % > Jerome Friedman, Trevor Hastie, and Robert Tibshirani. "Additive
    % > Logistic Regression: a Statistical View of Boosting". Technical
    % > Report, Dept. of Statistics, Stanford University, 1998.
    %
    % See also: cv.Boost.Boost, cv.DTrees, cv.RTrees, fitensemble
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
        % tree is pruned. Default value is 1.
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

        % Type of the boosting algorithm.
        %
        % Possible values are listed below. Gentle AdaBoost and Real AdaBoost
        % are often the preferable choices.
        %
        % * __Discrete__ Discrete AdaBoost.
        % * __Real__ Real AdaBoost. It is a technique that utilizes
        %       confidence-rated predictions and works well with categorical
        %       data. This is the default.
        % * __Logit__ LogitBoost. It can produce good regression fits.
        % * __Gentle__ Gentle AdaBoost. It puts less weight on outlier data
        %       points and for that reason is often good with regression data.
        BoostType
        % The number of weak classifiers.
        %
        % Default value is 100.
        WeakCount
        % A threshold between 0 and 1 used to save computational time.
        %
        % Samples with summary weight `<= 1-WeightTrimRate` do not participate
        % in the next iteration of training. Set this parameter to 0 to turn
        % off this functionality. Default value is 0.95.
        WeightTrimRate
    end

    %% Constructor/destructor
    methods
        function this = Boost(varargin)
            %BOOST  Creates/trains a new Boost model
            %
            %    model = cv.Boost()
            %    model = cv.Boost(...)
            %
            % The first variant creates an empty model. Use cv.Boost.train to
            % train the model, or cv.Boost.load to load a pre-trained model.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.Boost, cv.Boost.train
            %
            this.id = Boost_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.Boost
            %
            Boost_(this.id, 'delete');
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
            % See also: cv.Boost.empty, cv.Boost.load
            %
            Boost_(this.id, 'clear');
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
            % See also: cv.Boost.clear, cv.Boost.load
            %
            b = Boost_(this.id, 'empty');
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
            % See also: cv.Boost.load
            %
            [varargout{1:nargout}] = Boost_(this.id, 'save', filename);
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
            % See also: cv.Boost.save
            %
            Boost_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.Boost.save, cv.Boost.load
            %
            name = Boost_(this.id, 'getDefaultName');
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
            % See also: cv.Boost.train
            %
            count = Boost_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.Boost.empty, cv.Boost.train
            %
            b = Boost_(this.id, 'isTrained');
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
            % If `BoostType='Discrete'` the problem is classification, and
            % regression otherwise.
            %
            % See also: cv.Boost.isTrained
            %
            b = Boost_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains a boosted tree classifier
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
            % * __CompressedInput__ See the predict method. default false
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
            % The method trains the cv.Boost model.
            %
            % Depending on the `responses` data type (or the specified
            % `VarType` for the response), the method solves a classification
            % problem for categorical labels, otherwise the training is
            % treated as a regression problem for numerical responses.
            %
            % See also: cv.Boost.predict, cv.Boost.calcError
            %
            status = Boost_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.Boost.train, cv.Boost.predict
            %
            [err,resp] = Boost_(this.id, 'calcError', samples, responses, varargin{:});
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
            % The method runs the sample through the trees in the ensemble and
            % returns the output class label based on the weighted voting.
            %
            % See also: cv.Boost.train, cv.Boost.calcError
            %
            [results,f] = Boost_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% Boost
    methods
        function roots = getRoots(this)
            %GETROOS  Returns indices of root nodes
            %
            %    roots = classifier.getRoots()
            %
            % ## Output
            % * __roots__ vector of indices.
            %
            % See also: cv.Boost.getNodes
            %
            roots = Boost_(this.id, 'getRoots');
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
            % See also: cv.Boost.getRoots
            %
            nodes = Boost_(this.id, 'getNodes');
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
            % See also: cv.Boost.getSubsets, cv.Boost.getNodes
            %
            splits = Boost_(this.id, 'getSplits');
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
            % See also: cv.Boost.getSplits
            %
            subsets = Boost_(this.id, 'getSubsets');
        end
    end

    %% Getters/Setters
    methods
        function value = get.CVFolds(this)
            value = Boost_(this.id, 'get', 'CVFolds');
        end
        function set.CVFolds(this, value)
            Boost_(this.id, 'set', 'CVFolds', value);
        end

        function value = get.MaxCategories(this)
            value = Boost_(this.id, 'get', 'MaxCategories');
        end
        function set.MaxCategories(this, value)
            Boost_(this.id, 'set', 'MaxCategories', value);
        end

        function value = get.MaxDepth(this)
            value = Boost_(this.id, 'get', 'MaxDepth');
        end
        function set.MaxDepth(this, value)
            Boost_(this.id, 'set', 'MaxDepth', value);
        end

        function value = get.MinSampleCount(this)
            value = Boost_(this.id, 'get', 'MinSampleCount');
        end
        function set.MinSampleCount(this, value)
            Boost_(this.id, 'set', 'MinSampleCount', value);
        end

        function value = get.Priors(this)
            value = Boost_(this.id, 'get', 'Priors');
        end
        function set.Priors(this, value)
            Boost_(this.id, 'set', 'Priors', value);
        end

        function value = get.RegressionAccuracy(this)
            value = Boost_(this.id, 'get', 'RegressionAccuracy');
        end
        function set.RegressionAccuracy(this, value)
            Boost_(this.id, 'set', 'RegressionAccuracy', value);
        end

        function value = get.TruncatePrunedTree(this)
            value = Boost_(this.id, 'get', 'TruncatePrunedTree');
        end
        function set.TruncatePrunedTree(this, value)
            Boost_(this.id, 'set', 'TruncatePrunedTree', value);
        end

        function value = get.Use1SERule(this)
            value = Boost_(this.id, 'get', 'Use1SERule');
        end
        function set.Use1SERule(this, value)
            Boost_(this.id, 'set', 'Use1SERule', value);
        end

        function value = get.UseSurrogates(this)
            value = Boost_(this.id, 'get', 'UseSurrogates');
        end
        function set.UseSurrogates(this, value)
            Boost_(this.id, 'set', 'UseSurrogates', value);
        end

        function value = get.BoostType(this)
            value = Boost_(this.id, 'get', 'BoostType');
        end
        function set.BoostType(this, value)
            Boost_(this.id, 'set', 'BoostType', value);
        end

        function value = get.WeakCount(this)
            value = Boost_(this.id, 'get', 'WeakCount');
        end
        function set.WeakCount(this, value)
            Boost_(this.id, 'set', 'WeakCount', value);
        end

        function value = get.WeightTrimRate(this)
            value = Boost_(this.id, 'get', 'WeightTrimRate');
        end
        function set.WeightTrimRate(this, value)
            Boost_(this.id, 'set', 'WeightTrimRate', value);
        end
    end

end
