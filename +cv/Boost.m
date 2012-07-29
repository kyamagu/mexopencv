classdef Boost < handle
    %BOOST  Boosting
    %
    % A common machine learning task is supervised learning. In supervised
    % learning, the goal is to learn the functional relationship F: y = F(x)
    % between the input x and the output y. Predicting the qualitative output is
    % called classification, while predicting the quantitative output is called
    % regression.
    %
    % Boosting is a powerful learning concept that provides a solution to the
    % supervised classification learning task. It combines the performance of
    % many weak classifiers to produce a powerful committee [HTF01]. A weak
    % classifier is only required to be better than chance, and thus can be very
    % simple and computationally inexpensive. However, many of them smartly
    % combine results to a strong classifier that often outperforms most
    % monolithic strong classifiers such as SVMs and Neural Networks.
    %
    % Decision trees are the most popular weak classifiers used in boosting
    % schemes. Often the simplest decision trees with only a single split node
    % per tree (called stumps ) are sufficient.
    %
    % The boosted model is based on N training examples (xi,yi) with xi IN
    % R^k and yi IN {-1,+1}. xi is a K-component vector. Each component
    % encodes a feature relevant to the learning task at hand. The desired
    % two-class output is encoded as -1 and +1.
    %
    % Different variants of boosting are known as Discrete Adaboost, Real
    % AdaBoost, LogitBoost, and Gentle AdaBoost [FHT98]. All of them are very
    % similar in their overall structure.
    %
    % [FHT98] Friedman, J. H., Hastie, T. and Tibshirani, R. Additive Logistic
    % Regression: a Statistical View of Boosting. Technical Report, Dept. of
    % Statistics, Stanford University, 1998.
    %
    % See also cv.Boost.Boost cv.Boost.train cv.Boost.predict
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
        function this = Boost(varargin)
            %BOOST  Boosted tree classifier
            %
            %    classifier = cv.Boost
            %    classifier = cv.Boost(...)
            %
            % The constructor takes the same parameter to the train method.
            %
            % See also cv.Boost cv.Boost.train
            %
            this.id = Boost_();
            if nargin>0, this.train(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.Boost
            %
            Boost_(this.id, 'delete');
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
            % See also cv.Boost
            %
            Boost_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.Boost
            %
            Boost_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.Boost
            %
            Boost_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains a boosted tree classifier
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
            % * __BoostType__ Type of the boosting algorithm. Possible values
            %         are listed below. Gentle AdaBoost and Real AdaBoost are often the preferable
            %         choices. default 'Real'.
            %     * 'Discrete' Discrete AbaBoost.
            %     * 'Real'     Real AbaBoost. It is a technique that utilizes
            %                  confidence-rated predictions and works well
            %                  with categorical data.
            %     * 'Logit'    LogitBoost. It can produce good regression fits.
            %     * 'Gentle'   Gentle AdaBoost. It puts less weight on outlier
            %                  data points and for that reason is often good
            %                  with regression data.
            %
            % * __WeakCount__ The number of weak classifiers. default 100.
            % * __WeightTrimRate__ A threshold between 0 and 1 used to save
            %         computational time. Samples with summary weight <= 1 -
            %         WeightTrimRate do not participate in the next iteration of
            %         training. Set this parameter to 0 to turn off this
            %         functionality. default 0.95.
            % * __MaxDepth__ The maximum possible depth of the tree. That is
            %         the training algorithms attempts to split a node while its
            %         depth is less than max_depth. The actual depth may be
            %         smaller if the other termination criteria are met, and/or
            %         if the tree is pruned. default 1.
            % * __UseSurrogates__ If true then surrogate splits will be built.
            %         These splits allow to work with missing data and compute
            %         variable importance correctly. default true.
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
            % The method trains the Boost model.
            %
            % See also cv.Boost cv.Boost.predict
            %
            status = Boost_(this.id, 'train', trainData, responses, varargin{:});
        end
        
        function results = predict(this, samples, varargin)
            %PREDICT  Predicts responses for input samples
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
            % * __MissingMask__ Optional mask of missing measurements. To
            %         handle missing measurements, the weak classifiers must
            %         include surrogate splits.
            % * __Slice__ Continuous subset of the sequence of weak classifiers
            %         to be used for prediction. 2-element vector or ':' (all)
            %         is accepted. default ':'.
            % * __RawMode__ Normally, it should be set to false.
            % * __ReturnSum__ If true then return sum of votes instead of the
            %         class label.
            %
            % The method runs the sample through the trees in the ensemble and
            % returns the output class label based on the weighted voting.
            %
            % See also cv.Boost cv.Boost.train
            %
            results = Boost_(this.id, 'predict', samples, varargin{:});
        end
        
        function value = get.Params(this)
            %PARAMS  Returns the parameter
            value = Boost_(this.id, 'get_params');
        end
    end
    
end
