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
    % See also cv.SVM.SVM cv.SVM.train cv.SVM.predict cv.SVM.train_auto
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    properties (SetAccess = private, Dependent)
        % SVM training parameters
        Params
        % Number of used features (variables count)
        VarCount
        % Number of support vectors
        SupportVectorCount
    end
    
    methods
        function this = SVM(varargin)
            %SVM  Creates/trains a new SVM instance
            %
            %    classifier = cv.SVM
            %    classifier = cv.SVM(...)
            %
            % See also cv.SVM cv.SVM.train
            %
            this.id = SVM_();
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
            %CLEAR  Deallocates memory and resets the model state
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
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % The method `save` saves the complete model state to the specified
            % XML or YAML file
            %
            % See also cv.SVM cv.SVM.load
            %
            SVM_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % The method `load` loads the complete model state from the specified
            % XML or YAML file. The previous model state is cleared by `clear()`.
            %
            % See also cv.SVM cv.SVM.save
            %
            SVM_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains an SVM model
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(trainData, responses, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __trainData__ Row vectors of feature.
            % * __responses__ Output of the corresponding feature vectors.
            %
            % ## Output
            % * __status__ Success flag.
            %
            % ## Options
            % * __VarIdx__ Indicator variables (features) of interest. default none.
            % * __SampleIdx__ Indicator samples of interest. default none.
            % * __SVMType__ Type of a SVM formulation. See [LibSVM] for details.
            %         Possible values are:
            %     * 'C_SVC'     C-Support Vector Classification. n-class
            %                   classification (n>=2), allows imperfect separation
            %                   of classes with penalty multiplier `C` for outliers.
            %                   This is the default.
            %     * 'NU_SVC'    Nu-Support Vector Classification. n-class
            %                   classification with possible imperfect separation.
            %                   Parameter `Nu` (in the range 0..1, the larger the value,
            %                   the smoother the decision boundary) is used instead
            %                   of `C`.
            %     * 'ONE_CLASS' Distribution Estimation (One-class SVM). All the
            %                   training data are from the same class, SVM builds
            %                   a boundary that separates the class from the rest
            %                   of the feature space.
            %     * 'EPS_SVR'   P-Support Vector Regression. The distance between
            %                   feature vectors from the training set and the fitting
            %                   hyper-plane must be less than `p`. For outliers the
            %                   penalty multiplier `C` is used.
            %     * 'NU_SVR'    Nu-Support Vector Regression. `Nu` is used instead of `p`.
            % * __KernelType__ Type of a SVM kernel. Possible values are:
            %     * 'Linear'    Linear kernel. No mapping is done, linear discrimination
            %                   (or regression) is done in the original feature space.
            %                   It is the fastest option.
            %     * 'Poly'      Polynomial kernel.
            %     * 'RBF'       Radial basis function (RBF), a good choice in most cases.
            %                   This is the default kernel.
            %     * 'Sigmoid'   Sigmoid kernel.
            % * __Degree__ Parameter `degree` of a kernel function (`POLY`). default 0.
            % * __Gamma__ Parameter `gamma` of a kernel function (`POLY`, `RBF`, `SIGMOID`).
            %         The default is 1.
            % * __Coef0__ Parameter `coef0` of a kernel function (`POLY`, `SIGMOID`).
            %         The default is 0.
            % * __C__ Parameter `C` of a SVM optimiazation problem (`C_SVC`, `EPS_SVR`, `NU_SVR`).
            %         The default is 1.
            % * __Nu__ Parameter `nu` of a SVM optimization problem (`NU_SVC`, `ONE_CLASS`, `NU_SVR`).
            %         The default is 0.
            % * __P__ Parameter `p` of a SVM optimization problem (`EPS_SVR`).
            %         The default is 0.
            % * __ClassWeights__ Optional weights in the `C_SVC` problem, assigned
            %         to particular classes. They are multiplied by `C` so the parameter
            %         `C` of class `#i` becomes `ClassWeight(i) * C`. Thus these weights affect the
            %         misclassification penalty for different classes. The larger
            %         weight, the larger penalty on misclassification of data from
            %         the corresponding class. Default none.
            % * __TermCrit__ Termination criteria of the iterative SVM training
            %         procedure which solves a partial case of constrained quadratic
            %         optimization problem. You can specify tolerance and/or the
            %         maximum number of iterations. A struct with the
            %         following fields are accepted:
            %     * 'type'      one of {'Count','EPS','Count+EPS'}. default 'Count+EPS'
            %     * 'maxCount'  maximum number of iterations. default 1000
            %     * 'epsilon'   tolerance value. default `eps('single')`
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
            % See also cv.SVM cv.SVM.train_auto
            %
            status = SVM_(this.id, 'train', trainData, responses, varargin{:});
        end
        
        function status = train_auto(this, trainData, responses, varargin)
            %TRAIN_AUTO  Trains an SVM with optimal parameters
            %
            %    classifier.train_auto(trainData, responses)
            %    classifier.train_auto(trainData, responses, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __trainData__ Row vectors of feature.
            % * __responses__ Output of the corresponding feature vectors.
            %
            % ## Output
            % * __status__ Success flag.
            %
            % ## Options
            % All the options in `cv.SVM.train` are supported. In addition:
            %
            % * __KFold__ Cross-validation parameter. The training set is divided
            %         into `KFold` subsets. One subset is used to train the model,
            %         the others form the test set. So, the SVM algorithm is executed
            %         `KFold` times. default 10
            % * __Balanced__ If true and the problem is 2-class classification then
            %         the method creates more balanced cross-validation subsets that
            %         is proportions between classes in subsets are close to such
            %         proportion in the whole train dataset. default false
            % * __CGrid__, __GammaGrid__, __NuGrid__, __PGrid__, __CoeffGrid__, __DegreeGrid__
            %         Iteration grid for the corresponding SVM parameter. It accepts
            %         a struct having `{'min_val', 'max_val', 'log_step'}` fields, or
            %         a 3-element vector in which each parameter is specified in
            %         the same order to the struct is supported. Defaults are:
            %     * 'CGrid'     : `struct('min_val',0.1,  'max_val',500, 'log_step',5 )`
            %     * 'GammaGrid' : `struct('min_val',1e-5, 'max_val',0.6, 'log_step',15)`
            %     * 'PGrid'     : `struct('min_val',0.01, 'max_val',100, 'log_step',7 )`
            %     * 'NuGrid'    : `struct('min_val',0.01, 'max_val',0.2, 'log_step',3 )`
            %     * 'CoeffGrid' : `struct('min_val',0.1,  'max_val',300, 'log_step',14)`
            %     * 'DegreeGrid': `struct('min_val',0.01, 'max_val',4,   'log_step',7 )`
            %
            % The method trains the SVM model automatically by choosing the optimal parameters
            % `C`, `Gamma`, `P`, `Nu`, `Coef0`, `Degree` of an SVM model. Parameters are
            % considered optimal when the cross-validation estimate of the test set error
            % is minimal.
            %
            % If there is no need to optimize a parameter, the corresponding grid step
            % should be set to any value less than or equal to 1. For example, to avoid
            % optimization in gamma, set `log_step = 0` in `GammaGrid`, and `min_val`,
            % `max_val` as arbitrary numbers. In this case, the value of the parameter
            % `Gamma` is taken for gamma.
            %
            % This function works for the classification (`C_SVC` or `NU_SVC`) as well as
            % for the regression (`EPS_SVR` or `NU_SVR`). For `ONE_CLASS`, no optimization
            % is made and the usual SVM with the specified parameters is executed.
            %
            % See also cv.SVM cv.SVM.train
            %
            status = SVM_(this.id, 'train_auto', trainData, responses, varargin{:});
        end
        
        function results = predict(this, samples, varargin)
            %PREDICT  Predicts the response for input samples.
            %
            %    results = classifier.predict(samples)
            %
            % ## Input
            % * __samples__ Input sample(s) for prediction.
            %
            % ## Output
            % * __results__ Output prediction responses for corresponding samples.
            %
            % ## Options
            % * __ReturnDFVal__ Specifies a type of the return value. If
            %         true and the problem is 2-class classification then
            %         the method returns the decision function value that
            %         is signed distance to the margin, else the function
            %         returns a class label (classification) or estimated
            %         function value (regression).
            %
            % The method estimates the most probable classes for input vectors.
            % Input vectors (one or more) are stored as rows of the matrix
            % samples.
            %
            % The method is used to predict the response for a new sample. In case of a
            % classification, the method returns the class label. In case of a regression,
            % the method returns the output function value. The input sample must have as
            % many components as the `trainData` passed to `train()` contains. If the
            % `Varidx` parameter is passed to `train()`, it is remembered and then is used
            % to extract only the necessary components from the input sample in the method
            % `predict`.
            %
            % See also cv.SVM cv.SVM.predict_all
            %
            results = SVM_(this.id, 'predict', samples, varargin{:});
        end
        
        function results = predict_all(this, samples)
            %PREDICT_ALL  Predicts the response for input samples.
            %
            %    results = classifier.predict_all(samples)
            %
            % ## Input
            % * __samples__ Input samples for prediction.
            %
            % ## Output
            % * __results__ Output prediction responses for corresponding samples.
            %
            % The function is parallelized with the TBB library.
            %
            % See also cv.SVM cv.SVM.predict
            %
            results = SVM_(this.id, 'predict_all', samples);
        end
        
        function value = get.Params(this)
            %PARAMS
            value = SVM_(this.id, 'get_params');
        end
        
        function value = get.VarCount(this)
            %VARCOUNT
            value = SVM_(this.id, 'get_var_count');
        end
        
        function value = get.SupportVectorCount(this)
            %SUPPORTVECTORCOUNT
            value = SVM_(this.id, 'get_support_vector_count');
        end
        
        function sv = getSupportVector(this, index)
            %GETSUPPORTVECTOR  Retrieve a particular support vector.
            %
            %    sv = classifier.getSupportVector(index)
            %
            % ## Input
            % * __index__ 0-based scalar index of support vector. The index
            %         must be between 0 and classifier.SupportVectorCount - 1.
            %
            % ## Output
            % * __sv__ Support vector
            %
            % The method can be used to retrieve a support vector by index.
            %
            % See also cv.SVM.SupportVectorCount
            %
            assert(isscalar(index) && isnumeric(index));
            sv = SVM_(this.id, 'get_support_vector', index);
        end
    end
    
end
