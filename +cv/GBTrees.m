classdef GBTrees < handle
    %GBTREES  Gradient Boosted Trees
    %
    % Gradient Boosted Trees (GBT) is a generalized boosting algorithm
    % introduced by Jerome Friedman:
    % http://www.salfordsystems.com/doc/GreedyFuncApproxSS.pdf .
    % In contrast to the AdaBoost.M1 algorithm, GBT can deal with both
    % multiclass classification and regression problems. Moreover, it can use
    % any differential loss function, some popular ones are implemented.
    % Decision trees (CvDTree) usage as base learners allows to process ordered
    % and categorical variables.
    %
    % See also cv.GBTrees.GBTrees cv.GBTrees.train cv.GBTrees.predict
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        CVFolds
        MaxCategories
        MaxDepth
        MinSampleCount
        Priors
        RegressionAccuracy
        TruncatePrunedTree
        Use1SERule
        UseSurrogates
        WeakCount
        LossFunctionType
        SubsamplePortion
        Shrinkage
    end

    methods
        function this = GBTrees(varargin)
            %GBTREES  GBTrees classifier
            %
            %    classifier = cv.GBTrees
            %    classifier = cv.GBTrees(...)
            %
            % The constructor takes the same parameter to the train method.
            %
            % See also cv.GBTrees cv.GBTrees.train
            %
            this.id = GBTrees_(0, 'new');
            if nargin>0, this.train(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.GBTrees
            %
            GBTrees_(this.id, 'delete');
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
            % See also cv.GBTrees
            %
            GBTrees_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.GBTrees
            %
            GBTrees_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.GBTrees
            %
            GBTrees_(this.id, 'load', filename);
        end
        
        function status = train(this, samples, responses, varargin)
            %TRAIN  Trains a Gradient boosted tree model
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
            % * __LossFunctionType__ Type of the loss function used for
            %         training. It must be one of the following types:
            %         'Squared', 'Absolute', 'Huber', 'Deviance'. The first
            %         three types are used for regression problems, and the last
            %         one for classification. default 'Squared'.
            % * __WeakCount__ Count of boosting algorithm iterations.
            %         WeakCount*K is the total count of trees in the GBT model,
            %         where K is the output classes count (equal to one in case
            %         of a regression). default 200.
            % * __Shrinkage__ Regularization parameter. default 0.8.
            % * __SubsamplePortion__ Portion of the whole training set used for
            %         each algorithm iteration. Subset is generated randomly.
            %         For more information see
            %         http://www.salfordsystems.com/doc/StochasticBoostingSS.pdf
            % * __MaxDepth__ The maximum possible depth of the tree. That is
            %         the training algorithms attempts to split a node while its
            %         depth is less than MaxDepth. The actual depth may be
            %         smaller if the other termination criteria are met, and/or
            %         if the tree is pruned. default 1.
            % * __UseSurrogates__ If true then surrogate splits will be built.
            %         These splits allow to work with missing data and compute
            %         variable importance correctly. default true.
            %
            % The method trains the GBTrees model.
            %
            % See also cv.GBTrees cv.GBTrees.predict
            %
            status = GBTrees_(this.id, 'train_', samples, responses, varargin{:});
        end
        
        function [results,f] = predict(this, samples, varargin)
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
            % * __MissingMask__ Missing values mask, which is a
            %         dimentional matrix of the same size as sample having the
            %         uint8 type. 1 corresponds to the missing value in the same
            %         position in the sample vector. If there are no missing
            %         values in the feature vector, an empty matrix can be
            %         passed instead of the missing mask. default none.
            % * __Slice__ Parameter defining the part of the ensemble used for
            %         prediction. If slice = Range::all(), all trees are used.
            %         Use this parameter to get predictions of the GBT models
            %         with different ensemble sizes learning only one model.
            %         2-element vector or ':' (all) is accepted. default ':'.
            % * __K__ Number of tree ensembles built in case of the
            %         classification problem. Use this parameter to change the
            %         ouput to sum of the trees predictions in the k-th
            %         ensemble only. To get the total GBT model prediction, k
            %         value must be -1. For regression problems, k is also equal
            %         to -1. default -1.
            %
            % The method predicts the response corresponding to the given
            % sample. The result is either the class label or the estimated
            % function value. The method enables using the parallel version of
            % the GBT model prediction if the OpenCV is built with the TBB
            % library. In this case, predictions of single trees are computed in
            % a parallel fashion.
            %
            % See also cv.GBTrees cv.GBTrees.train
            %
            [results,f] = GBTrees_(this.id, 'predict', samples, varargin{:});
        end
    end

    methods
        function value = get.CVFolds(this)
            value = GBTrees_(this.id, 'get', 'CVFolds');
        end
        function set.CVFolds(this, value)
            GBTrees_(this.id, 'set', 'CVFolds', value);
        end

        function value = get.MaxCategories(this)
            value = GBTrees_(this.id, 'get', 'MaxCategories');
        end
        function set.MaxCategories(this, value)
            GBTrees_(this.id, 'set', 'MaxCategories', value);
        end

        function value = get.MaxDepth(this)
            value = GBTrees_(this.id, 'get', 'MaxDepth');
        end
        function set.MaxDepth(this, value)
            GBTrees_(this.id, 'set', 'MaxDepth', value);
        end

        function value = get.MinSampleCount(this)
            value = GBTrees_(this.id, 'get', 'MinSampleCount');
        end
        function set.MinSampleCount(this, value)
            GBTrees_(this.id, 'set', 'MinSampleCount', value);
        end

        function value = get.Priors(this)
            value = GBTrees_(this.id, 'get', 'Priors');
        end
        function set.Priors(this, value)
            GBTrees_(this.id, 'set', 'Priors', value);
        end

        function value = get.RegressionAccuracy(this)
            value = GBTrees_(this.id, 'get', 'RegressionAccuracy');
        end
        function set.RegressionAccuracy(this, value)
            GBTrees_(this.id, 'set', 'RegressionAccuracy', value);
        end

        function value = get.TruncatePrunedTree(this)
            value = GBTrees_(this.id, 'get', 'TruncatePrunedTree');
        end
        function set.TruncatePrunedTree(this, value)
            GBTrees_(this.id, 'set', 'TruncatePrunedTree', value);
        end

        function value = get.Use1SERule(this)
            value = GBTrees_(this.id, 'get', 'Use1SERule');
        end
        function set.Use1SERule(this, value)
            GBTrees_(this.id, 'set', 'Use1SERule', value);
        end

        function value = get.UseSurrogates(this)
            value = GBTrees_(this.id, 'get', 'UseSurrogates');
        end
        function set.UseSurrogates(this, value)
            GBTrees_(this.id, 'set', 'UseSurrogates', value);
        end

        function value = get.WeakCount(this)
            value = GBTrees_(this.id, 'get', 'WeakCount');
        end
        function set.WeakCount(this, value)
            GBTrees_(this.id, 'set', 'WeakCount', value);
        end

        function value = get.LossFunctionType(this)
            value = GBTrees_(this.id, 'get', 'LossFunctionType');
        end
        function set.LossFunctionType(this, value)
            GBTrees_(this.id, 'set', 'LossFunctionType', value);
        end

        function value = get.SubsamplePortion(this)
            value = GBTrees_(this.id, 'get', 'SubsamplePortion');
        end
        function set.SubsamplePortion(this, value)
            GBTrees_(this.id, 'set', 'SubsamplePortion', value);
        end

        function value = get.Shrinkage(this)
            value = GBTrees_(this.id, 'get', 'Shrinkage');
        end
        function set.Shrinkage(this, value)
            GBTrees_(this.id, 'set', 'Shrinkage', value);
        end
    end

end
