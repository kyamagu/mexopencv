classdef SVM < handle
    %SVM  Support Vector Machines
    %
    % ## Support Vector Machines
    %
    % Originally, support vector machines (SVM) was a technique for building
    % an optimal binary (2-class) classifier. Later the technique was extended
    % to regression and clustering problems. SVM is a partial case of
    % kernel-based methods. It maps feature vectors into a higher-dimensional
    % space using a kernel function and builds an optimal linear
    % discriminating function in this space or an optimal hyper-plane that
    % fits into the training data. In case of SVM, the kernel is not defined
    % explicitly. Instead, a distance between any 2 points in the hyper-space
    % needs to be defined.
    %
    % The solution is optimal, which means that the margin between the
    % separating hyper-plane and the nearest feature vectors from both classes
    % (in case of 2-class classifier) is maximal. The feature vectors that are
    % the closest to the hyper-plane are called support vectors, which means
    % that the position of other vectors does not affect the hyper-plane (the
    % decision function).
    %
    % SVM implementation in OpenCV is based on [LibSVM].
    %
    % cv.SVM implements the "one-against-one" approach for multi-class
    % classification. If `N` is the number of classes, then `N*(N-1)/2`
    % classifiers are constructed, each one trained with data from two classes
    % for every pair of distinct classes (`N` choose 2).
    %
    % ## References
    % [LibSVM]:
    % > C.-C. Chang and C.-J. Lin. "LIBSVM: a library for support vector machines",
    % > ACM Transactions on Intelligent Systems and Technology, 2:27:1-27:27, 2011.
    % > (http://www.csie.ntu.edu.tw/~cjlin/papers/libsvm.pdf)
    %
    % [Burges98]:
    % > C. Burges. "A tutorial on support vector machines for pattern recognition",
    % > Knowledge Discovery and Data Mining 2(2), 1998
    % > (http://citeseer.ist.psu.edu/burges98tutorial.html)
    %
    % See also: cv.SVM.SVM, cv.SVM.train, cv.SVM.predict, cv.SVM.trainAuto,
    %  fitcsvm
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Type of a SVM formulation.
        %
        % Default value is 'C_SVC'. Possible values:
        %
        % * **C_SVC** C-Support Vector Classification. n-class classification
        %       (`n>=2`), allows imperfect separation of classes with penalty
        %       multiplier `C` for outliers.
        % * **NU_SVC** Nu-Support Vector Classification. n-class
        %       classification with possible imperfect separation. Parameter
        %       `Nu` (in the range 0..1, the larger the value, the smoother
        %       the decision boundary) is used instead of `C`.
        % * **ONE_CLASS** Distribution Estimation (One-class SVM). All the
        %       training data are from the same class, SVM builds a boundary
        %       that separates the class from the rest of the feature space.
        % * **EPS_SVR** P-Support Vector Regression. The distance between
        %       feature vectors from the training set and the fitting
        %       hyper-plane must be less than `P`. For outliers the penalty
        %       multiplier `C` is used.
        % * **NU_SVR** Nu-Support Vector Regression. `Nu` is used instead of
        %       `P`. See [LibSVM] for details.
        Type
        % Type of a SVM kernel.
        %
        % Default value is 'RBF'. One of the following predefined kernels:
        %
        % * __Custom__ Returned by property in case when custom kernel has
        %       been set. See cv.SVM.setCustomKernel.
        % * __Linear__ Linear kernel. No mapping is done, linear
        %       discrimination (or regression) is done in the original feature
        %       space. It is the fastest option. `K(x_i,x_j) = x_i' * x_j`.
        % * __Poly__ Polynomial kernel.
        %       `K(x_i,x_j) = (gamma * x_i' * x_j + coef0)^degree, gamma>0`.
        % * __RBF__ Radial basis function (RBF), a good choice in most cases.
        %       `K(x_i,x_j) = exp(-gamma * ||x_i - x_j||^2), gamma>0`.
        % * __Sigmoid__ Sigmoid kernel.
        %       `K(x_i,x_j) = tanh(gamma * x_i' * x_j + coef0)`.
        % * __Chi2__ Exponential Chi2 kernel, similar to the RBF kernel.
        %       `K(x_i,x_j) = exp(-gamma * X2(x_i,x_j))`,
        %       `X2(x_i,x_j) = (x_i - x_j)^2 / (x_i + x_j), gamma>0`.
        % * __Intersection__ Histogram intersection kernel. A fast kernel.
        %       `K(x_i,x_j) = min(x_i,x_j)`.
        KernelType
        % Parameter `degree` of a kernel function.
        %
        % For 'Poly'. Default value is 0.
        Degree
        % Parameter `gamma` of a kernel function.
        %
        % For 'Poly', 'RBF', 'Sigmoid' or 'Chi2'. Default value is 1.
        Gamma
        % Parameter `coef0` of a kernel function.
        %
        % For 'Poly' or 'Sigmoid'. Default value is 0.
        Coef0
        % Parameter `C` of a SVM optimization problem.
        %
        % For 'C_SVC', 'EPS_SVR', or 'NU_SVR'. Default 1
        C
        % Parameter `nu` of a SVM optimization problem.
        %
        % For 'NU_SVC', 'ONE_CLASS' or 'NU_SVR'. Default value is 0.
        Nu
        % Parameter `epsilon` of a SVM optimization problem.
        %
        % For 'EPS_SVR'. Default value is 0.
        P
        % Optional weights in the 'C_SVC' problem, assigned to particular
        % classes.
        %
        % They are multiplied by `C` so the parameter `C` of class `i` becomes
        % `ClassWeights(i) * C`. Thus these weights affect the
        % misclassification penalty for different classes. The larger weight,
        % the larger penalty on misclassification of data from the
        % corresponding class. Not set by default (empty array `[]`).
        ClassWeights
        % Termination criteria.
        %
        % Termination criteria of the iterative SVM training procedure which
        % solves a partial case of constrained quadratic optimization problem.
        % You can specify tolerance and/or the maximum number of iterations.
        % A struct with the following fields is accepted:
        %
        % * __type__ one of 'Count', 'EPS', 'Count+EPS'. default 'Count+EPS'
        % * __maxCount__ maximum number of iterations. default 1000
        % * __epsilon__ tolerance value. default `eps('single')`
        TermCriteria
    end

    %% Constructor/destructor
    methods
        function this = SVM(varargin)
            %SVM  Creates/trains a new SVM instance
            %
            %    model = cv.SVM()
            %    model = cv.SVM(...)
            %
            % The first variant creates an empty model. Use cv.SVM.train to
            % train the model. Since SVM has several parameters, you may want
            % to find the best parameters for your problem, it can be done
            % with cv.SVM.trainAuto.
            %
            % The second variant accepts the same parameters as the train
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.SVM, cv.SVM.train, cv.SVM.load
            %
            this.id = SVM_(0, 'new');
            if nargin > 0
                this.train(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.SVM
            %
            SVM_(this.id, 'delete');
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
            % See also: cv.SVM.empty, cv.SVM.load
            %
            SVM_(this.id, 'clear');
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
            % See also: cv.SVM.clear, cv.SVM.load
            %
            b = SVM_(this.id, 'empty');
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
            % See also: cv.SVM.load
            %
            [varargout{1:nargout}] = SVM_(this.id, 'save', filename);
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
            % See also: cv.SVM.save
            %
            SVM_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SVM.save, cv.SVM.load
            %
            name = SVM_(this.id, 'getDefaultName');
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
            % See also: cv.SVM.train
            %
            count = SVM_(this.id, 'getVarCount');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained
            %
            %    b = model.isTrained()
            %
            % ## Output
            % * __b__ Returns true if the model is trained, false otherwise.
            %
            % See also: cv.SVM.empty, cv.SVM.train
            %
            b = SVM_(this.id, 'isTrained');
        end

        function b = isClassifier(this)
            %ISCLASSIFIER  Returns true if the model is a classifier
            %
            %    b = model.isClassifier()
            %
            % ## Output
            % * __b__ Returns true if the model is a classifier ('C_SVC',
            %       'NU_SVC', or 'ONE_CLASS'), false if the model is a
            %       regressor ('EPS_SVR', 'NU_SVR').
            %
            % See also: cv.SVM.isTrained
            %
            b = SVM_(this.id, 'isClassifier');
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
            % * __responses__ matrix of associated responses. If the responses
            %       are scalar, they should be stored as a vector (as a single
            %       row or a single column matrix). The matrix should have
            %       type `single` or `int32` (in the former case the responses
            %       are considered as ordered (numerical) by default; in the
            %       latter case as categorical). You can override the defaults
            %       using the `VarType` option.
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
            % The method trains the SVM model. It follows the conventions of
            % the generic train approach with the following limitations:
            %
            % * Input variables are all ordered.
            % * Output variables can be either categorical (`Type=C_SVC` or
            %   `Type=NU_SVC`), or ordered (`Type=EPS_SVR` or `Type=NU_SVR`),
            %   or not required at all (`Type=ONE_CLASS`).
            % * Missing measurements are not supported.
            %
            % SVM models may be trained on a selected feature subset, and/or
            % on a selected sample subset of the training set. To make it
            % easier for you, the data options include the `VarIdx` and
            % `SampleIdx` parameters. The former parameter identifies
            % variables (features) of interest, and the latter one identifies
            % samples of interest. Both vectors are either integer vectors
            % (lists of 0-based indices) or logical masks of active
            % variables/samples. You may pass empty input instead of either of
            % the arguments, meaning that all of the variables/samples are
            % used for training.
            %
            % ### Example
            % For example, an `Nx4` samples matrix of row layout with four
            % numerical variables and one categorical response variable `Nx1`
            % can be specified as:
            %
            %    model.train(samples, responses, 'Flags',0, ...
            %        'Data',{'Layout','Row', 'VarType','NNNNC'});
            %
            % ### Example
            % You can also directly load a dataset from a CSV file:
            %
            %    model.train('C:\path\to\data.csv', [], 'Flags',0, ...
            %        'Data',{'HeaderLineCount',1, 'Delimiter',','});
            %
            % See also: cv.SVM.trainAuto, cv.SVM.predict, cv.SVM.calcError
            %
            status = SVM_(this.id, 'train', samples, responses, varargin{:});
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
            % See also: cv.SVM.train, cv.SVM.predict
            %
            [err,resp] = SVM_(this.id, 'calcError', samples, responses, varargin{:});
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
            % * __results__ The output matrix of results.
            % * __f__ If you pass one sample then prediction result is
            %       returned here, otherwise unused and returns 0. If you want
            %       to get responses for several samples then `results` stores
            %       all response predictions for corresponding samples.
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent. For
            %       convenience, you can set the individual flag options
            %       below, instead of directly setting bits here. default 0
            % * __RawOutput__ makes the method return the raw results (the
            %      sum), not the class label. This flag specifies the type of
            %      the return value. If true and the problem is 2-class
            %      classification then the method returns the decision
            %      function value that is signed distance to the margin, else
            %      the function returns a class label (classification) or
            %      estimated function value (regression). default false
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.SVM.train, cv.SVM.calcError
            %
            [results,f] = SVM_(this.id, 'predict', samples, varargin{:});
        end
    end

    %% SVM
    methods
        function status = trainAuto(this, samples, responses, varargin)
            %TRAINAUTO  Trains an SVM with optimal parameters
            %
            %    status = model.trainAuto(samples, responses)
            %    status = model.trainAuto(csvFilename, [])
            %    [...] = model.trainAuto(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ See the train method.
            % * __responses__ See the train method.
            % * __csvFilename__ See the train method.
            %
            % ## Output
            % * __status__ Success flag.
            %
            % ## Options
            % * __Data__ See the train method.
            % * __KFold__ Cross-validation parameter. The training set is
            %       divided into `KFold` subsets. One subset is used to train
            %       the model, the others form the test set. So, the SVM
            %       algorithm is executed `KFold` times. default 10
            % * __Balanced__ If true and the problem is 2-class classification
            %       then the method creates more balanced cross-validation
            %       subsets that is proportions between classes in subsets are
            %       close to such proportion in the whole train dataset.
            %       default false
            % * __CGrid__, __GammaGrid__, __NuGrid__,
            %   __PGrid__, __CoeffGrid__, __DegreeGrid__
            %       Iteration grid for the corresponding SVM parameter.
            %       A structure that represents the logarithmic grid range of
            %       SVM parameters. It is used for optimizing model accuracy
            %       by varying model parameters, the accuracy estimate being
            %       computed by cross-validation. It accepts a struct having
            %       the fields below. It also accepts a 3-element vector in
            %       which each parameter is specified in the same order as the
            %       supported struct:
            %
            %       * __minVal__ Minimum value of the model parameter
            %       * __maxVal__ Maximum value of the model parameter
            %       * __logStep__ Logarithmic step for iterating the model
            %             parameter
            %
            %       The grid determines the following iteration sequence of
            %       the model parameter values: `minVal * logStep.^(0:n)`,
            %       where `n` is the maximal index satisfying
            %       `minVal*logStep^n < maxVal`. The grid is logarithmic, so
            %       `logStep` must always be greater then 1.
            %
            %       Defaults are:
            %
            %       * 'CGrid'     : `struct('minVal',0.1,  'maxVal',500, 'logStep',5 )`
            %       * 'GammaGrid' : `struct('minVal',1e-5, 'maxVal',0.6, 'logStep',15)`
            %       * 'PGrid'     : `struct('minVal',0.01, 'maxVal',100, 'logStep',7 )`
            %       * 'NuGrid'    : `struct('minVal',0.01, 'maxVal',0.2, 'logStep',3 )`
            %       * 'CoeffGrid' : `struct('minVal',0.1,  'maxVal',300, 'logStep',14)`
            %       * 'DegreeGrid': `struct('minVal',0.01, 'maxVal',4,   'logStep',7 )`
            %
            % The method trains the SVM model automatically by choosing the
            % optimal parameters `C`, `Gamma`, `P`, `Nu`, `Coef0`, `Degree` of
            % an SVM model. Parameters are considered optimal when the
            % cross-validation estimate of the test set error is minimal.
            %
            % If there is no need to optimize a parameter, the corresponding
            % grid step should be set to any value less than or equal to 1.
            % For example, to avoid optimization in gamma, set `logStep = 0`
            % in `GammaGrid`, and `minVal`, `maxVal` as arbitrary numbers. In
            % this case, the value of the parameter `Gamma` is taken for
            % gamma.
            %
            % And, finally, if the optimization in a parameter is required but
            % the corresponding grid is unknown, you may set it by name to
            % obtain the default grid of that parameter. To generate a grid,
            % for example, for gamma, set `GammaGrid='Gamma'`.
            %
            % This function works for the classification (`C_SVC` or `NU_SVC`)
            % as well as for the regression (`EPS_SVR` or `NU_SVR`). For
            % `ONE_CLASS`, no optimization is made and the usual SVM with the
            % specified parameters is executed.
            %
            % See also: cv.SVM.train, cv.SVM
            %
            status = SVM_(this.id, 'trainAuto', samples, responses, varargin{:});
        end

        function [alpha,svidx,rho] = getDecisionFunction(this, index)
            %GETDECISIONFUNCTION  Retrieves the decision function
            %
            %    [alpha,svidx,rho] = model.getDecisionFunction(index)
            %
            % ## Input
            % * __index__ the index of the decision function (0-based). If
            %       the problem solved is regression, 1-class or 2-class
            %       classification, then there will be just one decision
            %       function and the index should always be 0. Otherwise, in
            %       the case of N-class classification, there will be
            %       `N(N-1)/2` decision functions.
            %
            % ## Output
            % * __alpha__ the optional output vector for weights,
            %       corresponding to different support vectors. In the case of
            %       linear SVM all the alpha's will be 1's.
            % * __svidx__ the optional output vector of indices of support
            %       vectors within the matrix of support vectors (which can be
            %       retrieved by cv.SVM.getSupportVectors. In the case of
            %       linear SVM each decision function consists of a single
            %       "compressed" support vector.
            % * __rho__ `rho` parameter of the decision function, a scalar
            %       subtracted from the weighted sum of kernel responses.
            %
            % See also: cv.SVM.getSupportVectors
            %
            [alpha,svidx,rho] = SVM_(this.id, 'getDecisionFunction', index);
        end

        function sv = getSupportVectors(this)
            %GETSUPPORTVECTORS  Retrieves all the support vectors
            %
            %    sv = model.getSupportVectors()
            %
            % ## Output
            % * __sv__ All the support vector as floating-point matrix, where
            %       support vectors are stored as matrix rows.
            %
            % See also: cv.SVM.getDecisionFunction
            %
            sv = SVM_(this.id, 'getSupportVectors');
        end

        function setCustomKernel(this, kernelFunc)
            %SETCUSTOMKERNEL  Initialize with custom kernel
            %
            %    model.setCustomKernel(kernelFunc)
            %
            % ## Input
            % * __kernelFunc__ string, name of an M-function that implements a
            %       kernel function. See example below.
            %
            % ## Note
            % Parts of `cv::ml::SVM` implementation are thread-parallelized
            % (for example `SVM::predict` runs a `ParallelLoopBody`). By using
            % a custom kernel, we would be calling a MATLAB function
            % from C++ code using the MEX-API (`mexCallMATLAB`), which is not
            % thread-safe. This can cause MATLAB to crash. It is therefore
            % necessary to tempoararily disable threading in OpenCV when using
            % a custom SVM kernel (see cv.Utils.setNumThreads and
            % cv.Utils.getNumThreads).
            %
            % ## Example
            % The following MATLAB function implements a simple linear kernel.
            % The function must be saved in a separate M-file, and placed on
            % the MATLAB path. It receives an Nxd matrix of samples (each row
            % is a sample vector), and another sample 1xd (row vector), and
            % should return a vector Nx1  of inner products between every
            % sample in "vecs" against "another". It will be called during
            % training and prediction by the SVM class.
            %
            %    function results = my_custom_kernel(vecs, another)
            %        [vcount,n] = size(vecs);
            %        results = zeros(vcount, 1, 'single');
            %        for i=1:vcount
            %            results(i) = dot(vecs(i,:), another);
            %        end
            %
            %        % or computed in a vectorized manner as
            %        %results = sum(bsxfun(@times, vecs, another), 2);
            %
            %        % or simply written as matrix-vector product
            %        %results = vecs * another.';
            %    end
            %
            % We use the custom kernel in the following manner:
            %
            %    % load some data for classification
            %    load fisheriris
            %    samples = meas;
            %    responses = int32(grp2idx(species));
            %
            %    cv.Utils.setNumThreads(1)  % see above note
            %
            %    model = cv.SVM();
            %    model.setCustomKernel('my_custom_kernel');
            %    model.train(samples, responses)
            %    nnz(model.predict(samples) == responses)
            %
            %    cv.Utils.setNumThreads(cv.Utils.getNumberOfCPUs())
            %
            % See also: cv.SVM.KernelType
            %
            SVM_(this.id, 'setCustomKernel', kernelFunc);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Type(this)
            value = SVM_(this.id, 'get', 'Type');
        end
        function set.Type(this, value)
            SVM_(this.id, 'set', 'Type', value);
        end

        function value = get.KernelType(this)
            value = SVM_(this.id, 'get', 'KernelType');
        end
        function set.KernelType(this, value)
            SVM_(this.id, 'set', 'KernelType', value);
        end

        function value = get.Degree(this)
            value = SVM_(this.id, 'get', 'Degree');
        end
        function set.Degree(this, value)
            SVM_(this.id, 'set', 'Degree', value);
        end

        function value = get.Gamma(this)
            value = SVM_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            SVM_(this.id, 'set', 'Gamma', value);
        end

        function value = get.Coef0(this)
            value = SVM_(this.id, 'get', 'Coef0');
        end
        function set.Coef0(this, value)
            SVM_(this.id, 'set', 'Coef0', value);
        end

        function value = get.C(this)
            value = SVM_(this.id, 'get', 'C');
        end
        function set.C(this, value)
            SVM_(this.id, 'set', 'C', value);
        end

        function value = get.Nu(this)
            value = SVM_(this.id, 'get', 'Nu');
        end
        function set.Nu(this, value)
            SVM_(this.id, 'set', 'Nu', value);
        end

        function value = get.P(this)
            value = SVM_(this.id, 'get', 'P');
        end
        function set.P(this, value)
            SVM_(this.id, 'set', 'P', value);
        end

        function value = get.ClassWeights(this)
            value = SVM_(this.id, 'get', 'ClassWeights');
        end
        function set.ClassWeights(this, value)
            SVM_(this.id, 'set', 'ClassWeights', value);
        end

        function value = get.TermCriteria(this)
            value = SVM_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            SVM_(this.id, 'set', 'TermCriteria', value);
        end
    end

end
