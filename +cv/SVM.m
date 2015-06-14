classdef SVM < handle
    %SVM  Support Vector Machines
    %
    % Originally, support vector machines (SVM) was a technique for building an
    % optimal binary (2-class) classifier. Later the technique was extended to
    % regression and clustering problems. SVM is a partial case of kernel-based
    % methods. It maps feature vectors into a higher-dimensional space using a
    % kernel function and builds an optimal linear discriminating function in
    % this space or an optimal hyper-plane that fits into the training data. In
    % case of SVM, the kernel is not defined explicitly. Instead, a distance
    % between any 2 points in the hyper-space needs to be defined.
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
    % See also cv.SVM.SVM cv.SVM.train cv.SVM.predict cv.SVM.trainAuto
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Type of a SVM formulation. Default value is 'C_SVC'. Possible values:
        %
        % * **C_SVC** C-Support Vector Classification. n-class classification
        %       (n>=2), allows imperfect separation of classes with penalty
        %       multiplier `C` for outliers.
        % * **NU_SVC** Nu-Support Vector Classification. n-class classification
        %       with possible imperfect separation. Parameter `Nu` (in the range
        %       0..1, the larger the value, the smoother the decision boundary)
        %       is used instead of `C`.
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
        % Type of a SVM kernel. Default value is 'RBF'. Possible values are:
        %
        % * __Custom__ Returned by cv.SVM.getKernelType in case when custom
        %       kernel has been set.
        % * __Linear__ Linear kernel. No mapping is done, linear discrimination
        %       (or regression) is done in the original feature space. It is
        %       the fastest option. `K(x_i,x_j) = x_i' * x_j`.
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
        % Parameter degree of a kernel function. For 'Poly'.
        % Default value is 0.
        Degree
        % Parameter `gamma` of a kernel function. For 'Poly', 'RBF', 'Sigmoid'
        % or 'Chi2'. Default value is 1.
        Gamma
        % Parameter `coef0` of a kernel function. For 'Poly' or 'Sigmoid'.
        % Default value is 0.
        Coef0
        % Parameter `C` of a SVM optimization problem. For 'C_SVC', 'EPS_SVR',
        % or 'NU_SVR'. Default 1
        C
        % Parameter `nu` of a SVM optimization problem. For 'NU_SVC',
        % 'ONE_CLASS' or 'NU_SVR'. Default value is 0.
        Nu
        % Parameter `epsilon` of a SVM optimization problem. For 'EPS_SVR'.
        % Default value is 0.
        P
        % Optional weights in the 'C_SVC' problem, assigned to particular
        % classes. They are multiplied by `C` so the parameter `C` of class
        % `i` becomes `ClassWeights(i) * C`. Thus these weights affect the
        % misclassification penalty for different classes. The larger weight,
        % the larger penalty on misclassification of data from the
        % corresponding class. Default is none (empty array `[]`).
        ClassWeights
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

    methods
        function this = SVM(varargin)
            %SVM  Creates/trains a new SVM instance
            %
            %    classifier = cv.SVM
            %    classifier = cv.SVM(...)
            %
            % Creates an empty model. Use cv.SVM.train to train the model.
            % Since SVM has several parameters, you may want to find the best
            % parameters for your problem, it can be done with
            % cv.SVM.trainAuto.
            %
            % The constructor also accepts the same parameter as the train
            % method, in which case it forwards the call after construction.
            %
            % See also cv.SVM cv.SVM.train
            %
            this.id = SVM_(0, 'new');
            if nargin>0, this.train(varargin{:}); end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.SVM
            %
            SVM_(this.id, 'delete');
        end

        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    classifier.clear()
            %
            % The method clear does the same job as the destructor: it
            % deallocates all the memory occupied by the class members. But
            % the object itself is not destructed and can be reused
            % further. This method is called from the destructor, from the
            % train() methods, from load(), or even explicitly by the user.
            %
            % See also cv.SVM
            %
            SVM_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty.
            %
            %    obj.empty()
            %
            % (e.g. in the very beginning or after unsuccessful read).
            %
            b = SVM_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % The method `save` saves the complete model state to the specified
            % XML or YAML file
            %
            % See also cv.SVM cv.SVM.load
            %
            SVM_(this.id, 'save', filename);
        end

        function load(this, filename)
            %LOAD  Loads model from file or string.
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the model you want to load.
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
            % The method `load` loads the complete model state from the specified
            % XML or YAML file. The previous model state is discarded.
            %
            % See also cv.SVM cv.SVM.save
            %
            SVM_(this.id, 'load', filename);
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier.
            %
            %    obj.getDefaultName()
            %
            % This string is used as top level xml/yml node tag when the
            % object is saved to a file or string.
            %
            name = SVM_(this.id, 'getDefaultName');
        end

        function count = getVarCount(this)
            %GETVARCOUNT  Returns the number of variables in training samples.
            %
            count = SVM_(this.id, 'getVarCount');
        end

        function b = isClassifier(this)
            %ISCLASSIFIER  Returns true if the model is classifier.
            %
            b = SVM_(this.id, 'isClassifier');
        end

        function b = isTrained(this)
            %ISTRAINED  Returns true if the model is trained.
            %
            b = SVM_(this.id, 'isTrained');
        end

        function success = train(this, samples, responses, varargin)
            %TRAIN  Trains the statistical model.
            %
            %    success = model.train(samples, responses);
            %    [...] = model.train(..., 'OptionName', optionValue, ...);
            %
            % ## Inputs
            % * __samples__ training samples.
            % * __responses__ vector of responses associated with the training
            %       samples.
            %
            % ## Outputs
            % * __success__ success flag.
            %
            % ## Options
            % * __Layout__ see cv.SVM.train_ method.
            %
            % See also: cv.SVM.train_, cv.SVM.trainAuto
            %
            success = SVM_(this.id, 'train', samples, responses, varargin{:});
        end

        function status = train_(this, samples, responses, varargin)
            %TRAIN_  Trains the statistical model.
            %
            %    status = model.train_(samples, responses)
            %    [...] = model.train_(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ matrix of samples. It should have `single` type.
            % * __responses__ matrix of responses. If the responses are scalar,
            %       they should be stored as a single row or as a single
            %       column. The matrix should have type `single` or `int32`
            %       (in the former case the responses are considered as ordered
            %       (numerical) by default; in the latter case as categorical).
            %
            % ## Output
            % * __status__ Success flag.
            %
            % ## Options
            % * __Layout__ Sample types. Default 'Row'. A string, one of:
            %       * __Row__ each training sample is a row of samples.
            %       * __Col__ each training sample occupies a column of
            %             samples.
            % * __VarIdx__ vector specifying which variables to use for
            %       training. It can be an integer vector (`int32`) containing
            %       0-based variable indices or logical vector (`uint8` or
            %       `logical`) containing a mask of active variables.
            %       default none.
            % * __SampleIdx__ vector specifying which samples to use for
            %       training. It can be an integer vector (`int32`) containing
            %       0-based sample indices or logical vector (`uint8` or
            %       `logical`) containing a mask of training samples.
            %       default none.
            % * __SampleWeights__ optional vector with weights for each sample.
            %       It should have `single` type. default none.
            % * __VarType__ optional vector of type `uint8` and size
            %       `<num_of_vars_in_samples> + <num_of_vars_in_responses>`,
            %       containing types of each input and output variable.
            %       By default considers all variables as numerical (both input
            %       and output variables). In case there is only one output
            %       variable of integer type, it is considered categorical.
            %       You can also specify a cell-array of string, each one of:
            %       * __Numerical__, __N__ same as 'Ordered'
            %       * __Ordered__, __O__ ordered variables
            %       * __Categorical__, __C__ categorical variables
            % * __Flags__ The optional train flags, model-dependent. default 0
            % * __UpdateModel__ default false
            % * __RawOuput__ makes the method return the raw results (the sum),
            %      not the class label. default false
            % * __CompressedInput__ default false
            % * __PreprocessedInput__ default false
            %
            % The method trains the SVM model.
            %
            % SVM models may be trained on a selected feature subset, and/or on a selected
            % sample subset of the training set. To make it easier for you, the train
            % methods include the `VarIdx` and `SampleIdx` parameters. The former parameter
            % identifies variables (features) of interest, and the latter one identifies
            % samples of interest. Both vectors are either integer vectors (lists of
            % 0-based indices) or logical masks of active variables/samples. You may pass
            % empty input instead of either of the arguments, meaning that all of the
            % variables/samples are used for training.
            %
            % See also cv.SVM cv.SVM.train cv.SVM.trainAuto
            %
            status = SVM_(this.id, 'train_', samples, responses, varargin{:});
        end

        function status = trainAuto(this, samples, responses, varargin)
            %TRAINAUTO  Trains an SVM with optimal parameters
            %
            %    status = classifier.trainAuto(samples, responses)
            %    [...] = classifier.trainAuto(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ see cv.SVM.train_ method.
            % * __responses__ see cv.SVM.train_ method.
            %
            % ## Output
            % * __status__ Success flag.
            %
            % ## Options
            % All the options in `cv.SVM.train_` are supported. In addition:
            %
            % * __KFold__ Cross-validation parameter. The training set is divided
            %         into `KFold` subsets. One subset is used to train the model,
            %         the others form the test set. So, the SVM algorithm is executed
            %         `KFold` times. default 10
            % * __Balanced__ If true and the problem is 2-class classification then
            %         the method creates more balanced cross-validation subsets that
            %         is proportions between classes in subsets are close to such
            %         proportion in the whole train dataset. default false
            % * __CGrid__, __GammaGrid__, __NuGrid__,
            %   __PGrid__, __CoeffGrid__, __DegreeGrid__
            %         Iteration grid for the corresponding SVM parameter. It accepts
            %         a struct having `{'minVal', 'maxVal', 'logStep'}` fields, or
            %         a 3-element vector in which each parameter is specified in
            %         the same order to the struct is supported. Defaults are:
            %     * 'CGrid'     : `struct('minVal',0.1,  'maxVal',500, 'logStep',5 )`
            %     * 'GammaGrid' : `struct('minVal',1e-5, 'maxVal',0.6, 'logStep',15)`
            %     * 'PGrid'     : `struct('minVal',0.01, 'maxVal',100, 'logStep',7 )`
            %     * 'NuGrid'    : `struct('minVal',0.01, 'maxVal',0.2, 'logStep',3 )`
            %     * 'CoeffGrid' : `struct('minVal',0.1,  'maxVal',300, 'logStep',14)`
            %     * 'DegreeGrid': `struct('minVal',0.01, 'maxVal',4,   'logStep',7 )`
            %
            % The method trains the SVM model automatically by choosing the optimal parameters
            % `C`, `Gamma`, `P`, `Nu`, `Coef0`, `Degree` of an SVM model. Parameters are
            % considered optimal when the cross-validation estimate of the test set error
            % is minimal.
            %
            % If there is no need to optimize a parameter, the corresponding grid step
            % should be set to any value less than or equal to 1. For example, to avoid
            % optimization in gamma, set `logStep = 0` in `GammaGrid`, and `minVal`,
            % `maxVal` as arbitrary numbers. In this case, the value of the parameter
            % `Gamma` is taken for gamma.
            %
            % This function works for the classification (`C_SVC` or `NU_SVC`) as well as
            % for the regression (`EPS_SVR` or `NU_SVR`). For `ONE_CLASS`, no optimization
            % is made and the usual SVM with the specified parameters is executed.
            %
            % See also cv.SVM cv.SVM.train_
            %
            status = SVM_(this.id, 'trainAuto', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT  Predicts response(s) for the provided sample(s).
            %
            %    [results,f] = model.predict(samples);
            %    [...] = model.predict(..., 'OptionName', optionValue, ...);
            %
            % ## Inputs
            % * __samples__ The input samples, floating-point matrix.
            %
            % ## Outputs
            % * __results__ The optional output matrix of results.
            % * __f__
            %
            % ## Options
            % * __Flags__ The optional predict flags, model-dependent. default 0
            % * __UpdateModel__ default false
            % * __RawOuput__ makes the method return the raw results (the sum),
            %      not the class label. default false
            % * __CompressedInput__ default false
            % * __PreprocessedInput__ default false
            %
            % See also cv.SVM cv.SVM.train
            %
            [results, f] = SVM_(this.id, 'predict', samples, varargin{:});
        end

        function [resp,err] = calcError(this, samples, responses, test, varargin)
            %CALCERROR  Computes error on the training or test dataset.
            %
            %    [err,resp] = model.calcError(samples, responses, test);
            %    [...] = model.calcError(..., 'OptionName', optionValue, ...);
            %
            % ## Inputs
            % * __samples__ see cv.SVM.train_ method.
            % * __responses__ see cv.SVM.train_ method.
            % * __test__ if true, the error is computed over the test subset of
            %       the data, otherwise it's computed over the training subset
            %       of the data.
            %
            % ## Outputs
            % * __err__ computed error.
            % * __resp__ the optional output responses.
            %
            % ## Options
            % * __Layout__ see cv.SVM.train_ method.
            % * __VarIdx__ see cv.SVM.train_ method.
            % * __SampleIdx__ see cv.SVM.train_ method.
            % * __SampleWeights__ see cv.SVM.train_ method.
            % * __VarType__ see cv.SVM.train_ method.
            %
            % The method uses cv.SVM.predict to compute the error.
            % For regression models the error is computed as RMS, for
            % classifiers as a percent of missclassified samples (0%-100%).
            %
            [resp,err] = SVM_(this.id, 'calcError', samples, responses, test, varargin{:});
        end

        function [alpha,svidx,rho] = getDecisionFunction(this, index)
            %GETDECISIONFUNCTION  Retrieves the decision function.
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
            [alpha,svidx,rho] = SVM_(this.id, 'getDecisionFunction', index);
        end

        function sv = getSupportVectors(this)
            %GETSUPPORTVECTORS  Retrieves all the support vectors.
            %
            %    sv = classifier.getSupportVectors()
            %
            % ## Output
            % * __sv__ All the support vector as floating-point matrix, where
            %       support vectors are stored as matrix rows.
            %
            sv = SVM_(this.id, 'getSupportVectors');
        end

        function setCustomKernel(this, kernel_func)
            %SETCUSTOMKERNEL  Initialize with custom kernel.
            %
            %    classifier.setCustomKernel(kernel_func)
            %
            % ## Input
            % * **kernel_func** string, name of M-function.
            %
            % ## Note
            % Parts of cv::SVM implementation are thread-parallelized
            % (for example SVM::predict runs a ParallelLoopBody). By using
            % a custom kernel, we would be calling a MATLAB function
            % from C++ code using the MEX-API (`mexCallMATLAB`), which is not
            % thread-safe. This can cause MATLAB to crash. It is therefore
            % necessary to tempoararily disable threading in OpenCV when using
            % a custom SVM kernel (see cv.setNumThreads and cv.getNumThreads).
            %
            SVM_(this.id, 'setCustomKernel', kernel_func);
        end
    end

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
