classdef NormalBayesClassifier < handle
    %NormalBayesClassifier  Bayes classifier for normally distributed data
    %
    % This simple classification model assumes that feature vectors from
    % each class are normally distributed (though, not necessarily
    % independently distributed). So, the whole data distribution function
    % is assumed to be a Gaussian mixture, one component per class. Using
    % the training data the algorithm estimates mean vectors and covariance
    % matrices for every class, and then it uses them for prediction.
    %
    % See also cv.NormalBayesClassifier.NormalBayesClassifier
    % cv.NormalBayesClassifier.train cv.NormalBayesClassifier.predict
    %
    
    properties (SetAccess = private)
        id
    end
    
    methods
        function this = NormalBayesClassifier(varargin)
            %NORMALBAYESCLASSIFIER
            %
            %    classifier = cv.NormalBayesClassifier
            %
            % See also cv.NormalBayesClassifier
            %
            this.id = NormalBayesClassifier_();
            if nargin>0, this.train(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.NormalBayesClassifier
            %
            NormalBayesClassifier_(this.id, 'delete');
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
            % See also cv.NormalBayesClassifier
            %
            NormalBayesClassifier_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE  Saves the model to a file
            %
            %    classifier.save(filename)
            %
            % See also cv.NormalBayesClassifier
            %
            NormalBayesClassifier_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Loads the model from a file
            %
            %    classifier.load(filename)
            %
            % See also cv.NormalBayesClassifier
            %
            NormalBayesClassifier_(this.id, 'load', filename);
        end
        
        function status = train(this, trainData, responses, varargin)
            %TRAIN  Trains the model
            %
            %    classifier.train(trainData, responses)
            %    classifier.train(trainData, responses, 'OptionName', optionValue, ...)
            %
            %
            % ## Options
            % * __VarIdx__ Indicator variables (features) of interest.
            %         Must have the same size to responses.
            % * __SampleIdx__ Indicator samples of interest. Must have the
            %         the same size to responses.
            % * __Update__ Identifies whether the model should be trained
            %         from scratch (update=false) or should be updated using
            %         the new training data (update=true).
            %
            % The method trains the statistical model using a set of input
            % feature vectors and the corresponding output values (responses).
            % Both input and output vectors/values are passed as matrices.
            % The input feature vectors are stored as trainData rows, that
            % is, all the components (features) of a training vector are
            % stored continuously.
            %
            % Responses are usually stored in a 1D vector (a row or a column)
            % of integers.
            %
            % See also cv.NormalBayesClassifier
            %
            status = NormalBayesClassifier_(this.id, 'train', trainData,...
                responses, varargin{:});
        end
        
        function results = predict(this, samples)
            %PREDICT  Predicts the response for a sample
            %
            %    results = classifier.predict(samples)
            %
            % The method estimates the most probable classes for input vectors.
            % Input vectors (one or more) are stored as rows of the matrix
            % samples.
            %
            % See also cv.NormalBayesClassifier
            %
            results = NormalBayesClassifier_(this.id, 'predict', samples);
        end
    end
    
end
