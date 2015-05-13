classdef LogisticRegression < handle
    %LogisticRegression

    properties (SetAccess = private)
        id
    end

    properties (Dependent)
        Iterations
        LearningRate
        MiniBatchSize
        Regularization
        TermCriteria
        TrainMethod
    end

    methods
        function this = LogisticRegression(varargin)
            %LOGISTICREGRESSION
            %
            this.id = LogisticRegression_(0, 'new');
            if nargin>0, this.train(varargin{:}); end
        end

        function delete(this)
            %DELETE
            %
            LogisticRegression_(this.id, 'delete');
        end
        
        function clear(this)
            %CLEAR
            %
            LogisticRegression_(this.id, 'clear');
        end
        
        function save(this, filename)
            %SAVE
            %
            LogisticRegression_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD
            %
            LogisticRegression_(this.id, 'load', filename);
        end
        
        function status = train(this, samples, responses, varargin)
            %TRAIN
            %
            status = LogisticRegression_(this.id, 'train_', samples, responses, varargin{:});
        end

        function [results,f] = predict(this, samples, varargin)
            %PREDICT
            %
            [results,f] = LogisticRegression_(this.id, 'predict', samples, varargin{:});
        end

        function thetas = get_learnt_thetas(this)
            %GET_LEARNT_THETAS
            %
            thetas = LogisticRegression_(this.id, 'get_learnt_thetas');
        end
    end

    methods
        function value = get.Iterations(this)
            value = LogisticRegression_(this.id, 'get', 'Iterations');
        end
        function set.Iterations(this, value)
            LogisticRegression_(this.id, 'set', 'Iterations', value);
        end

        function value = get.LearningRate(this)
            value = LogisticRegression_(this.id, 'get', 'LearningRate');
        end
        function set.LearningRate(this, value)
            LogisticRegression_(this.id, 'set', 'LearningRate', value);
        end

        function value = get.MiniBatchSize(this)
            value = LogisticRegression_(this.id, 'get', 'MiniBatchSize');
        end
        function set.MiniBatchSize(this, value)
            LogisticRegression_(this.id, 'set', 'MiniBatchSize', value);
        end

        function value = get.Regularization(this)
            value = LogisticRegression_(this.id, 'get', 'Regularization');
        end
        function set.Regularization(this, value)
            LogisticRegression_(this.id, 'set', 'Regularization', value);
        end

        function value = get.TermCriteria(this)
            value = LogisticRegression_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            LogisticRegression_(this.id, 'set', 'TermCriteria', value);
        end

        function value = get.TrainMethod(this)
            value = LogisticRegression_(this.id, 'get', 'TrainMethod');
        end
        function set.TrainMethod(this, value)
            LogisticRegression_(this.id, 'set', 'TrainMethod', value);
        end
    end

end
