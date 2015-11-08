classdef NormalBayesClassifier < handle
    %NORMALBAYESCLASSIFIER  Bayes classifier for normally distributed data
    %
    % ## Normal Bayes Classifier
    %
    % This simple classification model assumes that feature vectors from
    % each class are normally distributed (though, not necessarily
    % independently distributed). So, the whole data distribution function
    % is assumed to be a Gaussian mixture, one component per class. Using
    % the training data the algorithm estimates mean vectors and covariance
    % matrices for every class, and then it uses them for prediction.
    %
    % ## References
    % [Fukunaga90]:
    % > K. Fukunaga. "Introduction to Statistical Pattern Recognition", 2e.
    % > New York: Academic Press, 1990.
    %
    % See also: cv.NormalBayesClassifier.NormalBayesClassifier,
    %  cv.NormalBayesClassifier.train, cv.NormalBayesClassifier.predict,
    %  fitcnb
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = NormalBayesClassifier(varargin)
            %NORMALBAYESCLASSIFIER  Creates/trains a new Bayes classifier model
            %
            %    model = cv.NormalBayesClassifier()
            %    model = cv.NormalBayesClassifier(...)
            %
            % The first variant creates an empty model. Use
            % cv.NormalBayesClassifier.train to train the model after
            % creation.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.NormalBayesClassifier, cv.NormalBayesClassifier.train
            %
            this.id = NormalBayesClassifier_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.NormalBayesClassifier
            %
            NormalBayesClassifier_(this.id, 'delete');
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
            % See also: cv.NormalBayesClassifier.empty, cv.NormalBayesClassifier.load
            %
            NormalBayesClassifier_(this.id, 'clear');
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
            % See also: cv.NormalBayesClassifier.clear, cv.NormalBayesClassifier.load
            %
            b = NormalBayesClassifier_(this.id, 'empty');
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
            % See also: cv.NormalBayesClassifier.load
            %
            [varargout{1:nargout}] = NormalBayesClassifier_(this.id, 'save', filename);
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
            % See also: cv.NormalBayesClassifier.save
            %
            NormalBayesClassifier_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.NormalBayesClassifier.save, cv.NormalBayesClassifier.load
            %
            name = NormalBayesClassifier_(this.id, 'getDefaultName');
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
            % See also: cv.NormalBayesClassifier.train
            %
            count = NormalBayesClassifier_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.NormalBayesClassifier.empty, cv.NormalBayesClassifier.train
            %
            b = NormalBayesClassifier_(this.id, 'isTrained');
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
            % Always true for bayes classifier.
            %
            % See also: cv.NormalBayesClassifier.isTrained
            %
            b = NormalBayesClassifier_(this.id, 'isClassifier');
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
            %       categorical labels.
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
            % * __UpdateModel__ Specifies whether the model should be trained
            %       from scratch (`UpdateModel=false`), or should be updated
            %       using the new training data (`UpdateModel=true`) instead
            %       of being completely overwritten. default false
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
            % The method trains the Normal Bayes classifier. It follows the
            % conventions of the generic train approach with the following
            % limitations:
            %
            % * Input variables are all ordered.
            % * Output variable is categorical, which means that elements of
            %   `responses` must be integer numbers, though the vector may
            %   have the `single` type.
            % * Missing measurements are not supported.
            %
            % The method trains the statistical model using a set of input
            % feature vectors and the corresponding output values (responses).
            % Both input and output vectors/values are passed as matrices.
            % The input feature vectors are stored as trainData rows, that
            % is, all the components (features) of a training vector are
            % stored continuously.
            %
            % Responses are usually stored in a 1D vector (a row or a column)
            % of integers.
            %
            % See also: cv.NormalBayesClassifier.predict, cv.NormalBayesClassifier.calcError
            %
            status = NormalBayesClassifier_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.NormalBayesClassifier.train, cv.NormalBayesClassifier.predict
            %
            [err,resp] = NormalBayesClassifier_(this.id, 'calcError', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts responses for input samples
            %
            %    [results,f] = model.predict(samples)
            %    [...] = model.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ The input samples, floating-point matrix. One or
            %       more vectors stored as rows of the matrix.
            %
            % ## Output
            % * __results__ The predicted class for each sample.
            % * __f__ unused and returns 0.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent. For
            %       convenience, you can set the individual flag options
            %       below, instead of directly setting bits here. default 0
            % * __RawOutput__ makes the method return the raw results (class
            %       index without mapping to class labels). default false
            %
            % The method is an alias for cv.KNearest.predictProb, without
            % returning the probabilities.
            %
            % See also: cv.NormalBayesClassifier.train, cv.NormalBayesClassifier.predictProb
            %
            [results,f] = NormalBayesClassifier_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% NormalBayesClassifier
    methods
        function [outputs,outputProbs,f] = predictProb(this, inputs, varargin)
            %PREDICTPROB  Predicts the response for sample(s)
            %
            %    outputs = model.predictProb(inputs)
            %    [outputs,outputProbs,f] = model.predictProb(inputs)
            %    [...] = model.predictProb(inputs, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __samples__ The input samples, floating-point matrix. One or
            %       more vectors stored as rows of the matrix.
            %
            % ## Output
            % * __outputs__ The predicted class for each sample.
            % * __outputProbs__ Matrix that contains the output probabilities
            %       corresponding to each element of result. (A matrix of size
            %       `nsamples-by-nclasses`). The probabilities are not
            %       normalized to the 0..1 range.
            % * __f__ unused and returns 0.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent. For
            %       convenience, you can set the individual flag options
            %       below, instead of directly setting bits here. default 0
            % * __RawOutput__ makes the method return the raw results (class
            %       index without mapping to class labels). default false
            %
            % The method estimates the most probable classes for input
            % vectors. Input vectors (one or more) are stored as rows of the
            % matrix inputs. In case of multiple input vectors, there should
            % be one output vector `outputs`. The matrix `outputProbs`
            % contains the output probabilities corresponding to each element
            % of result.
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.NormalBayesClassifier.predict, cv.NormalBayesClassifier.train
            %
            [outputs,outputProbs,f] = NormalBayesClassifier_(this.id, 'predictProb', inputs, varargin{:});
        end
    end

end
