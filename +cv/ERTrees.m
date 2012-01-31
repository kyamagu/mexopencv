classdef ERTrees < handle
    %ERTREES  Extremely randomized trees
    %
    % Extremely randomized trees have been introduced by Pierre Geurts, Damien
    % Ernst and Louis Wehenkel in the article “Extremely randomized trees”,
    % 2006 [http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.65.7485&rep=rep1&type=pdf].
    % The algorithm of growing Extremely randomized trees is similar to Random
    % Trees (Random Forest), but there are two differences:
    %
    %   1. Extremely randomized trees don’t apply the bagging procedure to
    %      constract the training samples for each tree. The same input training
    %      set is used to train all trees.
    %   2. Extremely randomized trees pick a node split very extremely (both a
    %      variable index and variable spliting value are chosen randomly),
    %      whereas Random Forest finds the best split (optimal one by variable
    %      index and variable spliting value) among random subset of variables.
    %
    % See also cv.RTrees cv.ERTrees.ERTrees cv.ERTrees.train cv.ERTrees.predict
    %
    
    properties (SetAccess = private)
        id
    end
    
    properties (SetAccess = private, Dependent)
    end
    
    methods
        function this = ERTrees
            %ERTREES  Random Trees classifier
            %
            %    classifier = cv.ERTrees
            %
            % See also cv.ERTrees
            %
            this.id = ERTrees_();
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.ERTrees
            %
            ERTrees_(this.id, 'delete');
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
            % See also cv.ERTrees
            %
            ERTrees_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.ERTrees
            %
            ERTrees_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.ERTrees
            %
            ERTrees_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains the Extremely Random Trees model
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
            %     'VarType': Solves classification problem when 'Categorical'.
            %         Otherwise, the training is treated as a regression problem.
            %         default 'Categorical'
			%     'MissingMask': Indicator mask for missing observation.
			%     'MaxDepth': The maximum possible depth of the tree. That is
			%         the training algorithms attempts to split a node while its
			%         depth is less than max_depth. The actual depth may be
			%         smaller if the other termination criteria are met, and/or
			%         if the tree is pruned. default 5.
			%     'MinSampleCount': If the number of samples in a node is less
			%         than this parameter then the node will not be splitted.
			%         default 10.
			%     'RegressionAccuracy': Termination criteria for regression
			%         trees. If all absolute differences between an estimated
			%         value in a node and values of train samples in this node
			%         are less than this parameter then the node will not be
			%         splitted. default 0.
			%     'UseSurrogates': If true then surrogate splits will be built.
			%         These splits allow to work with missing data and compute
			%         variable importance correctly. default false.
			%     'MaxCategories': Cluster possible values of a categorical
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
			%     'Priors': The array of a priori class probabilities, sorted by
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
			%     'CalcVarImportance': If true then variable importance will
			%         be calculated and then it can be retrieved by
			%         getVarImportance(). default false.
			%     'NActiveVars': The size of the randomly selected subset of
			%         features at each tree node and that are used to find the
			%         best split(s). If you set it to 0 then the size will be
			%         set to the square root of the total number of features.
			%         default 0.
			%     'MaxNumOfTreesInTheForest': The maximum number of trees in the
			%         forest (suprise, suprise). default 50.
			%     'ForestAccuracy': Sufficient accuracy (OOB error). default 0.1
			%     'TermCritType': The type of the termination criteria. One of
			%         'Iter', 'EPS', or 'Iter+EPS'. default 'Iter+EPS'
            %
            % The method trains the ERTrees model.
            %
            % See also cv.ERTrees cv.ERTrees.predict cv.ERTrees.predict_prob
            %
            status = ERTrees_(this.id, 'train', trainData, responses, varargin{:});
        end
        
        function results = predict(this, samples, varargin)
            %PREDICT  Predicts a response for an input sample
            %
            %    results = classifier.predict(samples)
            %
            % Input:
            %     samples: Input row vectors
            % Output:
            %     results: Output labels or regression values
            % Options:
            %     'MissingDataMask':  Missing values mask, which is a
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
            % See also cv.ERTrees cv.ERTrees.train cv.ERTrees.predict_prob
            %
            results = ERTrees_(this.id, 'predict', samples, varargin{:});
        end
        
        function results = predict_prob(this, samples, varargin)
            %PREDICT_PROB  Returns a fuzzy-predicted class label
            %
            %    results = classifier.predict(samples)
            %
            % Input:
            %     samples: Input row vectors
            % Output:
            %     results: Output labels or regression values
            % Options:
            %     'MissingMask':  Missing values mask, which is a
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
            % See also cv.ERTrees cv.ERTrees.train cv.ERTrees.predict
            %
            results = ERTrees_(this.id, 'predict_prob', samples, varargin{:});
        end
        
        function value = getVarImportance(this)
        	%GETVARIMPORTANCE  Returns the variable importance array
        	value = ERTrees_(this.id, 'getVarImportance');
        end
        
        function value = get_proximity(this, sample1, sample2, varargin)
        	%GET_PROXIMITY  Returns the variable importance array
        	value = ERTrees_(this.id, 'get_proximity', sample1, sample2, varargin{:});
        end
        
        function value = get_train_error(this)
        	%GET_TRAIN_ERROR  Returns the variable importance array
        	value = ERTrees_(this.id, 'get_train_error');
        end
        
        function value = get_tree_count(this)
        	%GET_TREE_COUNT  Returns the variable importance array
        	value = ERTrees_(this.id, 'get_tree_count');
        end
    end
    
end
