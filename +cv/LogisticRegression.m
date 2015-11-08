classdef LogisticRegression < handle
    %LOGISTICREGRESSION  Logistic Regression classifier
    %
    % ## Logistic Regression
    %
    % ML implements logistic regression, which is a probabilistic
    % classification technique. Logistic Regression is a binary classification
    % algorithm which is closely related to Support Vector Machines (SVM).
    % Like SVM, Logistic Regression can be extended to work on multi-class
    % classification problems like digit recognition (i.e. recognizing digitis
    % like 0,1 2, 3,... from the given images). This version of Logistic
    % Regression supports both binary and multi-class classifications (for
    % multi-class it creates a multiple 2-class classifiers). In order to
    % train the logistic regression classifier, Batch Gradient Descent and
    % Mini-Batch Gradient Descent algorithms are used (see [BatchDesWiki]).
    % Logistic Regression is a discriminative classifier (see [LogRegTomMitch]
    % for more details). Logistic  Regression is implemented as a C++ class in
    % cv.LogisticRegression.
    %
    % In Logistic Regression, we try to optimize the training paramater
    % `theta` such that the hypothesis `0 <= h_theta(x) <= 1` is acheived. We
    % have `h_theta(x) = g(h_theta(x))` and `g(z)=1/(1+e^(-z))` as the
    % logistic or sigmoid function. The term "Logistic" in Logistic Regression
    % refers to this function. For given data of a binary classification
    % problem of classes 0 and 1, one can determine that the given data
    % instance belongs to class 1 if `h_theta(x) >= 0.5` or class 0 if
    % `h_theta(x) < 0.5`.
    %
    % In Logistic Regression, choosing the right parameters is of utmost
    % importance for reducing the training error and ensuring high training
    % accuracy:
    %
    % * The learning rate can be set with `LearningRate` property. It
    %   determines how fast we approach the solution. It is a positive real
    %   number.
    % * Optimization algorithms like Batch Gradient Descent and Mini-Batch
    %   Gradient Descent are supported in cv.LogisticRegression. It is
    %   important that we mention the number of iterations these optimization
    %   algorithms have to run. The number of iterations can be set with
    %   `Iterations` property. This parameter can be thought as number of
    %   steps taken and learning rate specifies if it is a long step or a
    %   short step. This and previous parameter define how fast we arrive at a
    %   possible solution.
    % * In order to compensate for overfitting regularization is performed,
    %   which can be enabled with `Regularization` property. One can specify
    %   what kind of regularization has to be performed by passing one of
    %   regularization kinds to this property.
    % * Logistic regression implementation provides a choice of 2 training
    %   methods with Batch Gradient Descent or the MiniBatch Gradient Descent.
    %   To specify this, set `TrainMethod` property as either `Batch` or
    %   `MiniBatch`. If training method is set to `MiniBatch`, the size of the
    %   mini batch has to be to a postive integer set with `MiniBatchSize`
    %   property.
    %
    % ## Example
    % A sample set of training parameters for the Logistic Regression
    % classifier can be initialized as follows:
    %
    %    lr = cv.LogisticRegression();
    %    lr.LearningRate = 0.05;
    %    lr.Iterations = 1000;
    %    lr.Regularization = 'L2';
    %    lr.TrainMethod = 'MiniBatch';
    %    lr.MiniBatchSize = 10;
    %
    % ## References
    % [LogRegWiki]:
    % > http://en.wikipedia.org/wiki/Logistic_regression
    %
    % [BatchDesWiki]:
    % > http://en.wikipedia.org/wiki/Gradient_descent_optimization
    %
    % [LogRegTomMitch]:
    % > "Generative and Discriminative Classifiers: Naive Bayes and Logistic
    % > Regression" in Machine Learning, Tom Mitchell.
    % > http://www.cs.cmu.edu/~tom/NewChapters.html
    %
    % [RenMalik2003]:
    % > "Learning a Classification Model for Segmentation". Proc. CVPR, Nice,
    % > France (2003).
    %
    % See also: cv.LogisticRegression.LogisticRegression, fitglm
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The learning rate of the optimization algorithm.
        %
        % The higher the value, faster the rate and vice versa. If the value
        % is too high, the learning algorithm may overshoot the optimal
        % parameters and result in lower training accuracy. If the value is
        % too low, the learning algorithm converges towards the optimal
        % parameters very slowly. The value must a be a positive real number.
        % You can experiment with different values with small increments as in
        % 0.0001, 0.0003, 0.001, 0.003, 0.01, 0.03, 0.1, 0.3, ... and select
        % the learning rate with less training error. Default 0.001
        LearningRate
        % Number of iterations.
        %
        % The number of iterations required for the learing algorithm
        % (Gradient Descent or Mini Batch Gradient Descent). It has to be a
        % positive integer. You can try different number of iterations like in
        % 100, 1000, 2000, 3000, 5000, 10000, .. so on. Default 1000
        Iterations
        % Kind of regularization to be applied.
        %
        % Default 'L2'. Possible values:
        %
        % * __Disable__ Regularization disabled.
        % * __L1__ L1 norm.
        % * __L2__ L2 norm.
        Regularization
        % Kind of training method used to train the classifier.
        %
        % Default 'Batch'. Possible values:
        %
        % * __Batch__ batch gradient descent.
        % * __MiniBatch__ Mini-Batch Gradient Descent. Set `MiniBatchSize` to
        %       a positive integer when using this method.
        TrainMethod
        % Number of training samples taken in each step of Mini-Batch Gradient
        % Descent.
        %
        % Will only be used if using `MiniBatch` training algorithm. It has to
        % take values less than the total number of training samples.
        % Default 1
        MiniBatchSize
        % Termination criteria of the training algorithm.
        %
        % A struct with the following fields is accepted:
        %
        % * __type__ one of 'Count', 'EPS', 'Count+EPS'. default 'Count+EPS'
        % * __maxCount__ maximum number of iterations. default `Iterations`
        % * __epsilon__ tolerance value. default `LearningRate`
        TermCriteria
    end

    %% Constructor/destructor
    methods
        function this = LogisticRegression(varargin)
            %LOGISTICREGRESSION  Creates/trains a logistic regression model
            %
            %    model = cv.LogisticRegression()
            %    model = cv.LogisticRegression(...)
            %
            % The first variant creates Logistic Regression model with default
            % parameters.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.LogisticRegression, cv.LogisticRegression.train
            %
            this.id = LogisticRegression_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.LogisticRegression
            %
            LogisticRegression_(this.id, 'delete');
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
            % See also: cv.LogisticRegression.empty, cv.LogisticRegression.load
            %
            LogisticRegression_(this.id, 'clear');
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
            % See also: cv.LogisticRegression.clear, cv.LogisticRegression.load
            %
            b = LogisticRegression_(this.id, 'empty');
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
            % See also: cv.LogisticRegression.load
            %
            [varargout{1:nargout}] = LogisticRegression_(this.id, 'save', filename);
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
            % See also: cv.LogisticRegression.save
            %
            LogisticRegression_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.LogisticRegression.save, cv.LogisticRegression.load
            %
            name = LogisticRegression_(this.id, 'getDefaultName');
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
            % See also: cv.LogisticRegression.train
            %
            count = LogisticRegression_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.LogisticRegression.empty, cv.LogisticRegression.train
            %
            b = LogisticRegression_(this.id, 'isTrained');
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
            % Always true for logistic regression.
            %
            % See also: cv.LogisticRegression.isTrained
            %
            b = LogisticRegression_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains the statistical model
            %
            %    status = model.train(samples, responses)
            %    status = model.train(csvFilename, [])
            %    [...] = model.train(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ matrix of training samples. It should have
            %       `single` type. By default, each row represents a sample
            %       (see the `Layout` option).
            % * __responses__ matrix of associated responses. A vector of
            %       categorical labels, stored in an array of type `single`.
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
            % See also: cv.LogisticRegression.predict, cv.LogisticRegression.calcError
            %
            status = LogisticRegression_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.LogisticRegression.train, cv.LogisticRegression.predict
            %
            [err,resp] = LogisticRegression_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts responses for input samples
            %
            %    [results,f] = model.predict(samples)
            %    [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ The input data for the prediction algorithm. `MxN`
            %       matrix, where each row contains variables (features) of
            %       one object being classified. Should have `single` data
            %       type.
            %
            % ## Output
            % * __results__ Predicted labels as a column matrix of `int32`
            %       type.
            % * __f__ unused and returns 0.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent.
            %       Not used. default 0
            %
            % See also: cv.LogisticRegression.train, cv.LogisticRegression.calcError
            %
            [results,f] = LogisticRegression_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% LogisticRegression
    methods
        function thetas = getLearntThetas(this)
            %GETLEARNTTHETAS  Returns the trained paramters
            %
            %    thetas = classifier.getLearntThetas()
            %
            % ## Output
            % * __thetas__ It returns learnt paramters of the Logistic
            %       Regression as a matrix of type `single` arranged across
            %       rows. For a two-class classifcation problem, it returns a
            %       row matrix.
            %
            % See also: cv.LogisticRegression.train
            %
            thetas = LogisticRegression_(this.id, 'get_learnt_thetas');
        end
    end

    %% Getters/Setters
    methods
        function value = get.Iterations(this)
            value = LogisticRegression_(this.id, 'get', 'Iterations');
        end
        function set.Iterations(this, value)
            LogisticRegression_(this.id, 'set', 'Iterations', value);
        end

        function value = get.LearningRate(this)
            value = LogisticRegression_(this.id, 'get', 'LearningRate');
        end
        function set.LearningRate(this, value)
            LogisticRegression_(this.id, 'set', 'LearningRate', value);
        end

        function value = get.MiniBatchSize(this)
            value = LogisticRegression_(this.id, 'get', 'MiniBatchSize');
        end
        function set.MiniBatchSize(this, value)
            LogisticRegression_(this.id, 'set', 'MiniBatchSize', value);
        end

        function value = get.Regularization(this)
            value = LogisticRegression_(this.id, 'get', 'Regularization');
        end
        function set.Regularization(this, value)
            LogisticRegression_(this.id, 'set', 'Regularization', value);
        end

        function value = get.TermCriteria(this)
            value = LogisticRegression_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            LogisticRegression_(this.id, 'set', 'TermCriteria', value);
        end

        function value = get.TrainMethod(this)
            value = LogisticRegression_(this.id, 'get', 'TrainMethod');
        end
        function set.TrainMethod(this, value)
            LogisticRegression_(this.id, 'set', 'TrainMethod', value);
        end
    end

end
