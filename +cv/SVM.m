classdef SVM
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
    % http://www.csie.ntu.edu.tw/~cjlin/papers/libsvm.pdf
    %
    % See also cv.SVM.SVM cv.SVM.train cv.SVM.predict cv.SVM.train_auto
    %
    
    properties (SetAccess = private)
        id
    end
    
    properties (SetAccess = private, Dependent)
        Params
        VarCount
        SupportVectorCount
    end
    
    methods
        function this = SVM
            %SVM
            %
            %    classifier = cv.SVM
            %
            % See also cv.SVM
            %
            this.id = SVM_();
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
            % train() methods of the derived classes, from the methods
            % load(), or even explicitly by the user.
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
            % See also cv.SVM
            %
            SVM_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.SVM
            %
            SVM_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains the model
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(trainData, responses, 'OptionName', optionValue, ...)
            %
            % Input:
            %     trainData: Row vectors of feature.
            %     responses: Output of the corresponding feature vectors.
            % Options:
            %     'VarIdx': Indicator variables (features) of interest.
            %         Must have the same size to responses.
            %     'SampleIdx': Indicator samples of interest. Must have the
            %         the same size to responses.
            %     'SvmType': Type of a SVM formulation. Possible values are:
			%         'C_SVC'     C-Support Vector Classification. n-class
			%                     classification (n  2), allows imperfect separation
			%                     of classes with penalty multiplier C for outliers.
			%                     This is the default.
			%         'NU_SVC'    Nu-Support Vector Classification. n-class
			%                     classification with possible imperfect separation.
			%                     Parameter  (in the range 0..1, the larger the value,
			%                     the smoother the decision boundary) is used instead
			%                     of C.
			%         'ONE_CLASS' Distribution Estimation (One-class SVM). All the
			%                     training data are from the same class, SVM builds
			%                     a boundary that separates the class from the rest
			%                     of the feature space.
			%         'EPS_SVR'   Support Vector Regression. The distance between
			%                     feature vectors from the training set and the fitting
			%                     hyper-plane must be less than p. For outliers the
			%                     penalty multiplier C is used.
			%         'NU_SVR'    Nu-Support Vector Regression. Nu is used instead of p.
			%         See [LibSVM] for details.
			%     'KernelType': Type of a SVM kernel. Possible values are:
			%         'Linear'    Linear kernel. No mapping is done, linear discrimination
			%                     (or regression) is done in the original feature space.
			%                     It is the fastest option.
			%         'Poly'      Polynomial kernel.
			%         'RBF'       Radial basis function (RBF), a good choice in most cases.
			%                     This is the default kernel.
			%         'Sigmoid'   Sigmoid kernel.
			%     'Degree': Parameter degree of a kernel function (POLY). default 0.
			%     'Gamma': Parameter  of a kernel function (POLY / RBF / SIGMOID).
			%         The default is 1.
			%     'Coef0': Parameter coef0 of a kernel function (POLY / SIGMOID).
			%         The default is 0.
			%     'C': Parameter C of a SVM optimiazation problem (C_SVC / EPS_SVR / NU_SVR).
			%         The default is 1.
			%     'Nu': Parameter nu of a SVM optimization problem (NU_SVC / ONE_CLASS / NU_SVR).
			%         The default is 0.
			%     'P': Parameter p of a SVM optimization problem (EPS_SVR).
			%         The default is 0.
			%     'ClassWeights': Optional weights in the C_SVC problem, assigned
			%         to particular classes. They are multiplied by C so the parameter
			%         C of class #i becomes . Thus these weights affect the
			%         misclassification penalty for different classes. The larger
			%         weight, the larger penalty on misclassification of data from
			%         the corresponding class. Default none.
			%     'TermCrit': Termination criteria of the iterative SVM training
			%         procedure which solves a partial case of constrained quadratic
			%         optimization problem. You can specify tolerance and/or the
			%         maximum number of iterations. A struct with the
			%         following fields are accepted:
            %         'type'      one of {'Count','EPS','Count+EPS'}
            %         'maxCount'  maximum number of iterations
            %         'epsilon'   tolerance value
            %
            % The method trains the SVM model.
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
            % Input:
            %     trainData: Row vectors of feature.
            %     responses: Output of the corresponding feature vectors.
            % Options: All the options in cv.SVM.train are supported. In addition:
            %     'KFold': Cross-validation parameter. The training set is divided
            %         into KFold subsets. One subset is used to train the model,
            %         the others form the test set. So, the SVM algorithm is executed
            %         KFold times.
            %     'Balanced': If true and the problem is 2-class classification then
            %         the method creates more balanced cross-validation subsets that
            %         is proportions between classes in subsets are close to such
            %         proportion in the whole train dataset.
            %     'CGrid', 'GammaGrid', 'NuGrid', 'PGrid', 'CoeffGrid', 'DegreeGrid': 
            %         Iteration grid for the corresponding SVM parameter. It accepts
            %         a struct having {'min_val','max_val','log_step'} fields, or
            %         a 3-element vector in which each parameter is specified in
            %         the same order to the struct is supported.
            %
            % See also cv.SVM cv.SVM.train
            %
            status = SVM_(this.id, 'train_auto', trainData, responses, varargin{:});
        end
        
        function results = predict(this, samples)
            %PREDICT  Predicts the response for input samples.
            %
            %    results = classifier.predict(samples)
            %
            % The method estimates the most probable classes for input vectors.
            % Input vectors (one or more) are stored as rows of the matrix
            % samples.
            %
            % See also cv.SVM
            %
            results = SVM_(this.id, 'predict', samples);
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
    end
    
end
