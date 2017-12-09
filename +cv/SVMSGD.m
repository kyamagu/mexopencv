classdef SVMSGD < handle
    %SVMSGD  Stochastic Gradient Descent SVM classifier
    %
    % SVMSGD provides a fast and easy-to-use implementation of the SVM
    % classifier using the Stochastic Gradient Descent approach, as presented
    % in [bottou2010large].
    %
    % The classifier has following parameters:
    %
    % * model type,
    % * margin type,
    % * margin regularization (`lambda`),
    % * initial step size (`gamma_0`),
    % * step decreasing power (`c`),
    % * and termination criteria.
    %
    % The model type may have one of the following values: 'SGD' and 'ASGD'.
    %
    % * __SGD__ is the classic version of SVMSGD classifier: every next step
    %   is calculated by the formula:
    %
    %       w_{t+1} = w_t - gamma(t) * (dQ_i/dw)|_{w = w_t}
    %
    %   where
    %
    %   * `w_t` is the weights vector for decision function at step `t`,
    %   * `gamma(t)` is the step size of model parameters at the iteration
    %     `t`, it is decreased on each step by the formula
    %     `gamma(t) = gamma_0 * (1 + lambda*gamma_0*t)^(-c)`
    %   * `Q_i` is the target functional from SVM task for sample with
    %     number `i`, this sample is chosen stochastically on each step of
    %     the algorithm.
    %
    % * __ASGD__ is Average Stochastic Gradient Descent SVM Classifier. ASGD
    %   classifier averages weights vector on each step of algorithm by the
    %   formula `wHat_{t+1} = t/(1+t) * wHat_t + 1/(1+t) * w_{t+1}`.
    %
    % The recommended model type is ASGD (following [bottou2010large]).
    %
    % The margin type may have one of the following values:
    %
    % * __SoftMargin__ You should use 'HardMargin' type, if you have linearly
    %   separable sets.
    % * __HardMargin__ You should use 'SoftMargin' type, if you have
    %   non-linearly separable sets or sets with outliers.
    %
    % In the general case (if you know nothing about linear separability of
    % your sets), use 'SoftMargin'.
    %
    % The other parameters may be described as follows:
    %
    % * Margin regularization parameter is responsible for weights decreasing
    %   at each step and for the strength of restrictions on outliers (the
    %   less the parameter, the less probability that an outlier will be
    %   ignored). Recommended value for SGD model is 0.0001, for ASGD model
    %   is 0.00001.
    % * Initial step size parameter is the initial value for the step size
    %   `gamma(t)`. You will have to find the best initial step for your
    %   problem.
    % * Step decreasing power is the power parameter for `gamma(t)` decreasing
    %   by the formula, mentioned above. Recommended value for SGD model is 1,
    %   for ASGD model is 0.75.
    % * Termination criteria can be 'Count', 'EPS', or 'Count+EPS'. You will
    %   have to find the best termination criteria for your problem.
    %
    % Note that the parameters margin regularization, initial step size, and
    % step decreasing power should be positive.
    %
    % To use SVMSGD algorithm do as follows:
    %
    % * first, create the cv.SVMSGD object. The algorithm will set optimal
    %   parameters by default, but you can set your own parameters via
    %   properties cv.SVMSGD.SvmsgdType, cv.SVMSGD.MarginType,
    %   cv.SVMSGD.MarginRegularization, cv.SVMSGD.InitialStepSize, and
    %   cv.SVMSGD.StepDecreasingPower.
    % * then the SVM model can be trained using the train features and the
    %   correspondent labels by the method cv.SVMSGD.train.
    % * after that, the label of a new feature vector can be predicted using
    %   the method cv.SVMSGD.predict.
    %
    % Example:
    %
    %     % Create empty object
    %     svmsgd = cv.SVMSGD();
    %     % Train the Stochastic Gradient Descent SVM
    %     svmsgd.train(trainData);
    %     % Predict labels for the new samples
    %     svmsgd.predict(samples, responses);
    %
    % ## References
    % [bottou2010large]:
    % > Leon Bottou. "Large-scale machine learning with stochastic gradient
    % > descent". In Proceedings of COMPSTAT 2010, pages 177-186. Springer.
    %
    % See also: cv.SVMSGD.SVMSGD, cv.SVM, fitcsvm
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Algorithm type.
        %
        % Default value is 'ASGD' (often the preferable choice). One of:
        %
        % * __SGD__ Stochastic Gradient Descent.
        % * __ASGD__ Average Stochastic Gradient Descent.
        SvmsgdType
        % Margin type.
        %
        % Default 'SoftMargin'. One of:
        %
        % * __SoftMargin__ General case, suits to the case of non-linearly
        %   separable sets, allows outliers.
        % * __HardMargin__ More accurate for the case of linearly separable
        %   sets.
        MarginType
        % Parameter margin regularization of a SVMSGD optimization problem.
        MarginRegularization
        % Parameter initial step size of a SVMSGD optimization problem.
        InitialStepSize
        % Parameter step decreasing power of a SVMSGD optimization problem.
        StepDecreasingPower
        % Termination criteria of the training algorithm.
        %
        % You can specify the maximum number of iterations (`maxCount`) and/or
        % how much the error could change between the iterations to make the
        % algorithm continue (`epsilon`).
        % A struct with the following fields is accepted:
        %
        % * __type__ one of 'Count', 'EPS', 'Count+EPS'. default 'Count+EPS'
        % * __maxCount__ maximum number of iterations. default 1000
        % * __epsilon__ tolerance value. default `eps('single')`
        TermCriteria
    end

    %% Constructor/destructor
    methods
        function this = SVMSGD(varargin)
            %SVMSGD  Creates empty model
            %
            %     model = cv.SVMSGD()
            %     model = cv.SVMSGD(...)
            %
            % The first variant creates an empty model. Use cv.SVMSGD.train to
            % train the model. Since SVMSGD has several parameters, you may
            % want to find the best parameters for your problem or use
            % cv.SVMSGD.setOptimalParameters to set some default parameters.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.SVMSGD, cv.SVMSGD.train, cv.SVMSGD.load
            %
            this.id = SVMSGD_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     model.delete()
            %
            % See also: cv.SVMSGD
            %
            if isempty(this.id), return; end
            SVMSGD_(this.id, 'delete');
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
            % See also: cv.SVMSGD.empty, cv.SVMSGD.load
            %
            SVMSGD_(this.id, 'clear');
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
            % See also: cv.SVMSGD.clear, cv.SVMSGD.load
            %
            b = SVMSGD_(this.id, 'empty');
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
            % See also: cv.SVMSGD.load
            %
            [varargout{1:nargout}] = SVMSGD_(this.id, 'save', filename);
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
            % See also: cv.SVMSGD.save
            %
            SVMSGD_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SVMSGD.save, cv.SVMSGD.load
            %
            name = SVMSGD_(this.id, 'getDefaultName');
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
            % See also: cv.SVMSGD.train
            %
            count = SVMSGD_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %     b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.SVMSGD.empty, cv.SVMSGD.train
            %
            b = SVMSGD_(this.id, 'isTrained');
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
            % See also: cv.SVMSGD.isTrained
            %
            b = SVMSGD_(this.id, 'isClassifier');
        end

        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains the statistical model
            %
            %     status = model.train(samples, responses)
            %     status = model.train(csvFilename, [])
            %     [...] = model.train(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ matrix of training samples. It should have
            %   `single` type. By default, each row represents a sample (see
            %   the `Layout` option).
            % * __responses__ matrix of associated responses. If the responses
            %   are scalar, they should be stored as a vector (as a single row
            %   or a single column matrix). The matrix should have type
            %   `single` or `int32` (in the former case the responses are
            %   considered as ordered (numerical) by default; in the latter
            %   case as categorical). You can override the defaults using the
            %   `VarType` option.
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
            % * __Flags__ The optional training flags, model-dependent.
            %   Not used. default 0
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
            % See also: cv.SVMSGD.predict, cv.SVMSGD.calcError
            %
            status = SVMSGD_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.SVMSGD.train, cv.SVMSGD.predict
            %
            [err,resp] = SVMSGD_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts response(s) for the provided sample(s)
            %
            %     [results,f] = model.predict(samples)
            %     [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ The input samples, floating-point matrix.
            %
            % ## Output
            % * __results__ The output matrix of results.
            % * __f__ If you pass one sample then prediction result is
            %   returned here, otherwise unused and returns 0. If you want to
            %   get responses for several samples then `results` stores all
            %   response predictions for corresponding samples.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent.
            %   Not used. default 0
            %
            % See also: cv.SVMSGD.train, cv.SVMSGD.calcError
            %
            [results,f] = SVMSGD_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% SVMSGD
    methods
        function weights = getWeights(this)
            %GETWEIGHTS  Get model weights
            %
            %     weights = model.getWeights()
            %
            % ## Output
            % * __weights__ the weights of the trained model (decision
            %   function `f(x) = weights * x + shift`).
            %
            % See also: cv.SVMSGD.getShift
            %
            weights = SVMSGD_(this.id, 'getWeights');
        end

        function shift = getShift(this)
            %GETSHIFT  Get model shift
            %
            %     shift = model.getShift()
            %
            % ## Output
            % * __shift__ the shift of the trained model (decision function
            %   `f(x) = weights * x + shift`).
            %
            % See also: cv.SVMSGD.getWeights
            %
            shift = SVMSGD_(this.id, 'getShift');
        end

        function setOptimalParameters(this, varargin)
            %SETOPTIMALPARAMETERS  Function sets optimal parameters values for chosen SVM SGD model
            %
            %     model.setOptimalParameters('OptionName',optionValue, ...)
            %
            % ## Options
            % * __SvmsgdType__ the type of SVMSGD classifier, default 'ASGD'.
            % * __MarginType__ the type of margin constraint, default
            %   'SoftMargin'.
            %
            % This sets the properties `MarginRegularization`,
            % `InitialStepSize`, `StepDecreasingPower`, and `TermCriteria` to
            % optimal values according to model type.
            %
            % See also: cv.SVMSGD.SvmsgdType, cv.SVMSGD.MarginType
            %
            SVMSGD_(this.id, 'setOptimalParameters', varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.SvmsgdType(this)
            value = SVMSGD_(this.id, 'get', 'SvmsgdType');
        end
        function set.SvmsgdType(this, value)
            SVMSGD_(this.id, 'set', 'SvmsgdType', value);
        end

        function value = get.MarginType(this)
            value = SVMSGD_(this.id, 'get', 'MarginType');
        end
        function set.MarginType(this, value)
            SVMSGD_(this.id, 'set', 'MarginType', value);
        end

        function value = get.MarginRegularization(this)
            value = SVMSGD_(this.id, 'get', 'MarginRegularization');
        end
        function set.MarginRegularization(this, value)
            SVMSGD_(this.id, 'set', 'MarginRegularization', value);
        end

        function value = get.InitialStepSize(this)
            value = SVMSGD_(this.id, 'get', 'InitialStepSize');
        end
        function set.InitialStepSize(this, value)
            SVMSGD_(this.id, 'set', 'InitialStepSize', value);
        end

        function value = get.StepDecreasingPower(this)
            value = SVMSGD_(this.id, 'get', 'StepDecreasingPower');
        end
        function set.StepDecreasingPower(this, value)
            SVMSGD_(this.id, 'set', 'StepDecreasingPower', value);
        end

        function value = get.TermCriteria(this)
            value = SVMSGD_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            SVMSGD_(this.id, 'set', 'TermCriteria', value);
        end
    end

end
