classdef DTree < handle
    %DTREE  Decision Trees
    %
    % The ML classes discussed in this section implement Classification and
    % Regression Tree algorithms described in [Breiman84].
    %
    % The class CvDTree represents a single decision tree that may be used alone
    % or as a base class in tree ensembles (see Boosting and Random Trees).
    %
    % A decision tree is a binary tree (tree where each non-leaf node has two
    % child nodes). It can be used either for classification or for regression.
    % For classification, each tree leaf is marked with a class label; multiple
    % leaves may have the same label. For regression, a constant is also
    % assigned to each tree leaf, so the approximation function is piecewise
    % constant.
    %
    % See also cv.DTree.DTree cv.DTree.train cv.DTree.predict
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    properties (SetAccess = private, Dependent)
        % Object parameters
        Params
    end
    
    methods
        function this = DTree(varargin)
            %DTREE  Create a new instance of DTree
            %
            %    classifier = cv.DTree
            %    classifier = cv.DTree(...)
            %
            % The constructor takes the same parameter to the train method.
            %
            % See also cv.DTree cv.DTree.train
            %
            this.id = DTree_();
            if nargin>0, this.train(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.DTree
            %
            DTree_(this.id, 'delete');
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
            % See also cv.DTree
            %
            DTree_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.DTree
            %
            DTree_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.DTree
            %
            DTree_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains a decision tree
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __trainData__ Row vectors of feature.
            % * __responses__ Output of the corresponding feature vectors.
            %
            % ## Options
            % * __VarIdx__ Indicator variables (features) of interest.
            %         Must have the same size to responses.
            % * __SampleIdx__ Indicator samples of interest. Must have the
            %         the same size to responses.
            % * __VarType__ Solves classification problem when 'Categorical'.
            %         Otherwise, the training is treated as a regression problem.
            %         default 'Categorical'
            % * __MissingMask__ Indicator mask for missing observation.
            % * __MaxDepth__ The maximum possible depth of the tree. That is
            %         the training algorithms attempts to split a node while its
            %         depth is less than MaxDepth. The actual depth may be
            %         smaller if the other termination criteria are met, and/or
            %         if the tree is pruned. default INT\_MAX.
            % * __MinSampleCount__ If the number of samples in a node is less
            %         than this parameter then the node will not be splitted.
            %         default 10.
            % * __RegressionAccuracy__ Termination criteria for regression
            %         trees. If all absolute differences between an estimated
            %         value in a node and values of train samples in this node
            %         are less than this parameter then the node will not be
            %         splitted. default 0.01.
            % * __UseSurrogates__ If true then surrogate splits will be built.
            %         These splits allow to work with missing data and compute
            %         variable importance correctly. default true.
            % * __MaxCategories__ Cluster possible values of a categorical
            %         variable into K <= MaxCategories clusters to find a
            %         suboptimal split. If a discrete variable, on which the
            %         training procedure tries to make a split, takes more than
            %         MaxCategories values, the precise best subset estimation
            %         may take a very long time because the algorithm is
            %         exponential. Instead, many decision trees engines
            %         (including ML) try to find sub-optimal split in this case
            %         by clustering all the samples into MaxCategories clusters
            %         that is some categories are merged together. The
            %         clustering is applied only in n>2-class classification
            %         problems for categorical variables with N > MaxCategories
            %         possible values. In case of regression and 2-class
            %         classification the optimal split can be found efficiently
            %         without employing clustering, thus the parameter is not
            %         used in these cases. default 10.
            % * __CVFolds__ If CVFolds > 1 then prune a tree with K-fold
            %         cross-validation where K is equal to CVFolds. default 10.
            % * __Use1seRule__ If true then a pruning will be harsher. This
            %         will make a tree more compact and more resistant to the
            %         training data noise but a bit less accurate. default true.
            % * __TruncatePrunedTree__ If true then pruned branches are
            %         physically removed from the tree. Otherwise they are
            %         retained and it is possible to get results from the
            %         original unpruned (or pruned less aggressively) tree by
            %         decreasing PrunedTreeIdx parameter. default true.
            % * __Priors__ The array of a priori class probabilities, sorted by
            %         the class label value. The parameter can be used to tune
            %         the decision tree preferences toward a certain class. For
            %         example, if you want to detect some rare anomaly
            %         occurrence, the training base will likely contain much
            %         more normal cases than anomalies, so a very good
            %         classification performance will be achieved just by
            %         considering every case as normal. To avoid this, the
            %         priors can be specified, where the anomaly probability is
            %         artificially increased (up to 0.5 or even greater), so the
            %         weight of the misclassified anomalies becomes much bigger,
            %         and the tree is adjusted properly. You can also think
            %         about this parameter as weights of prediction categories
            %         which determine relative weights that you give to
            %         misclassification. That is, if the weight of the first
            %         category is 1 and the weight of the second category is 10,
            %         then each mistake in predicting the second category is
            %         equivalent to making 10 mistakes in predicting the first
            %         category. default none.
            %
            % The method trains the DTree model.
            %
            % See also cv.DTree
            %
            status = DTree_(this.id, 'train', trainData, responses, varargin{:});
        end
        
        function results = predict(this, samples, varargin)
            %PREDICT  Predicts the response for input samples.
            %
            %    results = classifier.predict(samples)
            %    [...] = classifier.predict(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Input row vectors
            %
            % ## Output
            % * __results__ Output labels or regression values
            %
            % ## Options
            % * __MissingMask__ Optional input missing measurement mask.
            % * __PreprocessedInput__ This parameter is normally set to false,
            %         implying a regular input. If it is true, the method
            %         assumes that all the values of the discrete input
            %         variables have been already normalized to 0 to #categories
            %         ranges since the decision tree uses such normalized
            %         representation internally. It is useful for faster
            %         prediction with tree ensembles. For ordered input
            %         variables, the flag is not used.
            %
            % The method estimates the most probable classes for input vectors.
            % Input vectors (one or more) are stored as rows of the matrix
            % samples.
            %
            % See also cv.DTree
            %
            results = DTree_(this.id, 'predict', samples, varargin{:});
        end
        
        function value = getVarImportance(this)
            %GETVARIMPORTANCE  Returns the variable importance array
            value = DTree_(this.id, 'getVarImportance');
        end
        
        function value = get.Params(this)
            %PARAMS
            value = DTree_(this.id, 'params');
        end
    end
    
end
