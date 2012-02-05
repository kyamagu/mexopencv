classdef KNearest < handle
    %KNearest  The class implements K-Nearest Neighbors model
    %
    % The algorithm caches all training samples and predicts the response for a
    % new sample by analyzing a certain number (K) of the nearest neighbors of
    % the sample using voting, calculating weighted sum, and so on. The method
    % is sometimes referred to as â€œlearning by exampleâ€ because for prediction
    % it looks for the feature vector with a known response that is closest to
    % the given vector.
    %
    % See also cv.KNearest.KNearest
    % cv.KNearest.train cv.KNearest.find_nearest
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    properties (SetAccess = private, Dependent)
        % Maximum number of K
        MaxK
        % Variable count
        VarCount
        % Sample count
        SampleCount
        % Logical flag to indicate regression problem
        IsRegression
    end
    
    methods
        function this = KNearest(varargin)
            %KNEAREST  K-Nearest Neighbors constructor
            %
            %    classifier = cv.KNearest
            %
            % See also cv.KNearest
            %
            this.id = KNearest_();
            if nargin>0, this.train(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.KNearest
            %
            KNearest_(this.id, 'delete');
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
            % See also cv.KNearest
            %
            KNearest_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.KNearest
            %
            KNearest_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.KNearest
            %
            KNearest_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains the model
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(trainData, responses, 'OptionName', optionValue, ...)
            %
            % Options:
            %     'IsRegression': Type of the problem: true for regression and
            %         false for classification.
            %     'MaxK': Number of maximum neighbors that may be passed to the
            %         method find_nearest.
            %     'SampleIdx': Indicator samples of interest. Must have the
            %         the same size to responses.
            %     'UpdateBase': Specifies whether the model is trained from
            %         scratch (update_base=false), or it is updated using the
            %         new training data (update_base=true). In the latter case,
            %         the parameter maxK must not be larger than the original
            %         value.
            %
            % The method trains the K-Nearest model.
            %
            % See also cv.KNearest
            %
            status = KNearest_(this.id, 'train', trainData,...
                responses, varargin{:});
        end
        
        function [results,neiResp,dists] = find_nearest(this, samples, varargin)
            %FIND_NEAREST  Finds the neighbors and predicts responses for input vectors
            %
            %    results = classifier.find_nearest(samples)
            %    results = classifier.find_nearest(samples, 'OptionName', optionValue, ...)
            %    [results,neiResp,dists] = classifier.find_nearest(...)
            %
            % For each input vector (a row of the matrix samples), the method
            % finds the k nearest neighbors. In case of regression, the
            % predicted result is a mean value of the particular vector'€™s
            % neighbor responses. In case of classification, the class is
            % determined by voting.
            %
            % For each input vector, the neighbors are sorted by their distances
            % to the vector.
            %
            % See also cv.KNearest
            %
            [results,neiResp,dists] = KNearest_(this.id, 'find_nearest', samples, varargin{:});
        end
        
        function [results,neiResp,dists] = predict(this, varargin)
            %PREDICT  Predicts the response for a sample
            %
            %    results = classifier.predict(samples)
            %    results = classifier.predict(samples, 'OptionName', optionValue, ...)
            %
            % The method is an alias for find_nearest
            %
            % See also cv.KNearest.find_nearest
            %
            [results,neiResp,dists] = this.find_nearest(varargin{:});
        end
        
        function value = get.MaxK(this)
        	%MAXK
        	value = KNearest_(this.id, 'get_max_k');
        end
        
        function value = get.VarCount(this)
        	%VARCOUNT
        	value = KNearest_(this.id, 'get_var_count');
        end
        
        function value = get.SampleCount(this)
        	%SAMPLECOUNT
        	value = KNearest_(this.id, 'get_sample_count');
        end
        
        function value = get.IsRegression(this)
        	%ISREGRESSION
        	value = KNearest_(this.id, 'is_regression');
        end
    end
    
end
