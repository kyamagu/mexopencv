classdef RTrees < handle
    %RTREES  Random Trees
    %
    % Random trees have been introduced by Leo Breiman and Adele Cutler:
    % http://www.stat.berkeley.edu/users/breiman/RandomForests/ . The algorithm
    % can deal with both classification and regression problems. Random trees is
    % a collection (ensemble) of tree predictors that is called forest further
    % in this section (the term has been also introduced by L. Breiman). The
    % classification works as follows: the random trees classifier takes the
    % input feature vector, classifies it with every tree in the forest, and
    % outputs the class label that recieved the majority of votes.In case of
    % a regression, the classifier response is the average of the responses over
    % all the trees in the forest.
    %
    % All the trees are trained with the same parameters but on different
    % training sets. These sets are generated from the original training set
    % using the bootstrap procedure: for each training set, you randomly select
    % the same number of vectors as in the original set ( =N ). The vectors are
    % chosen with replacement. That is, some vectors will occur more than once
    % and some will be absent. At each node of each trained tree, not all the
    % variables are used to find the best split, but a random subset of them.
    % With each node a new subset is generated. However, its size is fixed for
    % all the nodes and all the trees. It is a training parameter set to
    % sqrt(#variables) by default. None of the built trees are pruned.
    %
    % In random trees there is no need for any accuracy estimation procedures,
    % such as cross-validation or bootstrap, or a separate test set to get an
    % estimate of the training error. The error is estimated internally during
    % the training. When the training set for the current tree is drawn by
    % sampling with replacement, some vectors are left out (so-called oob
    % (out-of-bag) data ). The size of oob data is about N/3 . The
    % classification error is estimated by using this oob-data as follows:
    %
    % 1. Get a prediction for each vector, which is oob relative to the i-th
    %      tree, using the very i-th tree.
    % 2. After all the trees have been trained, for each vector that has ever
    %      been oob, find the class-winner for it (the class that has got the
    %      majority of votes in the trees where the vector was oob) and compare
    %      it to the ground-truth response.
    % 3. Compute the classification error estimate as a ratio of the number of
    %      misclassified oob vectors to all the vectors in the original data. In
    %      case of regression, the oob-error is computed as the squared error
    %      for oob vectors difference divided by the total number of vectors.
    %
    % * Machine Learning, Wald I, July 2002.
    %   http://stat-www.berkeley.edu/users/breiman/wald2002-1.pdf
    % * Looking Inside the Black Box, Wald II, July 2002.
    %   http://stat-www.berkeley.edu/users/breiman/wald2002-2.pdf
    % * Software for the Masses, Wald III, July 2002.
    %   http://stat-www.berkeley.edu/users/breiman/wald2002-3.pdf
    % * And other articles from the web site
    %   http://www.stat.berkeley.edu/users/breiman/RandomForests/cc_home.htm
    %
    % See also cv.RTrees.RTrees cv.RTrees.train cv.RTrees.predict
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    properties (SetAccess = private, Dependent)
        % Mask of active variables
        ActiveVarMask
        % Number of trees
        TreeCount
        % Object parameters
        Params
    end
    
    methods
        function this = RTrees(varargin)
            %RTREES  Random Trees classifier
            %
            %    classifier = cv.RTrees
            %    classifier = cv.RTrees(...)
            %
            % The constructor takes the same parameter to the train method.
            %
            % See also cv.RTrees cv.RTrees.train
            %
            this.id = RTrees_();
            if nargin>0, this.train(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.RTrees
            %
            RTrees_(this.id, 'delete');
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
            % See also cv.RTrees
            %
            RTrees_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.RTrees
            %
            RTrees_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.RTrees
            %
            RTrees_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains the Random Trees model
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(trainData, responses, 'OptionName', optionValue, ...)
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
            %         depth is less than max_depth. The actual depth may be
            %         smaller if the other termination criteria are met, and/or
            %         if the tree is pruned. default 5.
            % * __MinSampleCount__ If the number of samples in a node is less
            %         than this parameter then the node will not be splitted.
            %         default 10.
            % * __RegressionAccuracy__ Termination criteria for regression
            %         trees. If all absolute differences between an estimated
            %         value in a node and values of train samples in this node
            %         are less than this parameter then the node will not be
            %         splitted. default 0.
            % * __UseSurrogates__ If true then surrogate splits will be built.
            %         These splits allow to work with missing data and compute
            %         variable importance correctly. default false.
            % * __MaxCategories__ Cluster possible values of a categorical
            %         variable into K <= MaxCategories clusters to find a
            %         suboptimal split. If a discrete variable, on which the
            %         training procedure tries to make a split, takes more than
            %         MaxCategories values, the precise best subset estimation
            %         may take a very long time because the algorithm is
            %         exponential. Instead, many decision trees engines
            %         (including ML) try to find sub-optimal split in this case
            %         by clustering all the samples into max_categories clusters
            %         that is some categories are merged together. The
            %         clustering is applied only in n>2-class classification
            %         problems for categorical variables with N > max_categories
            %         possible values. In case of regression and 2-class
            %         classification the optimal split can be found efficiently
            %         without employing clustering, thus the parameter is not
            %         used in these cases. default 0.
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
            % * __CalcVarImportance__ If true then variable importance will
            %         be calculated and then it can be retrieved by
            %         getVarImportance(). default false.
            % * __NActiveVars__ The size of the randomly selected subset of
            %         features at each tree node and that are used to find the
            %         best split(s). If you set it to 0 then the size will be
            %         set to the square root of the total number of features.
            %         default 0.
            % * __MaxNumOfTreesInTheForest__ The maximum number of trees in the
            %         forest (suprise, suprise). default 50.
            % * __ForestAccuracy__ Sufficient accuracy (OOB error). default 0.1
            % * __TermCritType__ The type of the termination criteria. One of
            %         'Iter', 'EPS', or 'Iter+EPS'. default 'Iter+EPS'
            %
            % The method trains the RTrees model.
            %
            % See also cv.RTrees cv.RTrees.predict cv.RTrees.predict_prob
            %
            status = RTrees_(this.id, 'train', trainData, responses, varargin{:});
        end
        
        function results = predict(this, samples, varargin)
            %PREDICT  Predicts a response for an input sample
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
            % * __MissingDataMask__ Missing values mask, which is a
            %         dimentional matrix of the same size as sample having the
            %         uint8 type. 1 corresponds to the missing value in the same
            %         position in the sample vector. If there are no missing
            %         values in the feature vector, an empty matrix can be
            %         passed instead of the missing mask. default none.
            %
            % This method returns the cumulative result from all the trees in
            % the forest (the class that receives the majority of voices, or the
            % mean of the regression function estimates).
            %
            % See also cv.RTrees cv.RTrees.train cv.RTrees.predict_prob
            %
            results = RTrees_(this.id, 'predict', samples, varargin{:});
        end
        
        function results = predict_prob(this, samples, varargin)
            %PREDICT_PROB  Returns a fuzzy-predicted class label
            %
            %    results = classifier.predict_prob(samples)
            %    [...] = classifier.predict_prob(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Input row vectors
            %
            % ## Output
            % * __results__ Output labels or regression values
            %
            % ## Options
            % * __MissingMask__ Missing values mask, which is a
            %         dimentional matrix of the same size as sample having the
            %         uint8 type. 1 corresponds to the missing value in the same
            %         position in the sample vector. If there are no missing
            %         values in the feature vector, an empty matrix can be
            %         passed instead of the missing mask. default none.
            %
            % The function works for binary classification problems only. It
            % returns the number between 0 and 1. This number represents
            % probability or confidence of the sample belonging to the second
            % class. It is calculated as the proportion of decision trees that
            % classified the sample to the second class.
            %
            % See also cv.RTrees cv.RTrees.train cv.RTrees.predict
            %
            results = RTrees_(this.id, 'predict_prob', samples, varargin{:});
        end
        
        function value = getVarImportance(this)
            %GETVARIMPORTANCE  Returns the variable importance array
            value = RTrees_(this.id, 'getVarImportance');
        end
        
        function value = get_proximity(this, sample1, sample2, varargin)
            %GET_PROXIMITY  Retrieves the proximity measure between two training samples
            %
            %    value = classifier.get_proximity(sample1, sample2)
            %    [...] = classifier.get_proximity(..., 'OptionName', optionValue, ...)
            %
            %
            % ## Options
            % * __Missing1__ Missing values mask for sample1
            % * __Missing2__ Missing values mask for sample2
            %
            value = RTrees_(this.id, 'get_proximity', sample1, sample2, varargin{:});
        end
        
        function value = get_train_error(this)
            %GET_TRAIN_ERROR  Returns the training error
            value = RTrees_(this.id, 'get_train_error');
        end
        
        function value = get_tree_count(this)
            %GET_TREE_COUNT  Returns the number of trees in the constructed random forest
            value = RTrees_(this.id, 'get_tree_count');
        end
        
        function value = get.Params(this)
            %PARAMS
            value = RTrees_(this.id, 'params');
        end
        
        function value = get.ActiveVarMask(this)
            %ACTIVEVARMASK
            value = RTrees_(this.id, 'get_active_var_mask');
        end
        
        function value = get.TreeCount(this)
            %TREECOUNT  Returns the number of trees in the constructed random forest
            value = RTrees_(this.id, 'get_tree_count');
        end
    end
    
end
