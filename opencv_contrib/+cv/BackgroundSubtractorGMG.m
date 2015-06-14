classdef BackgroundSubtractorGMG < handle
    %BACKGROUNDSUBTRACTORGMG
    %
    % See also cv.BackgroundSubtractorGMG.BackgroundSubtractorGMG
    % cv.BackgroundSubtractorGMG.apply
    % cv.BackgroundSubtractorGMG.getBackgroundImage
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        BackgroundPrior
        DecisionThreshold
        DefaultLearningRate
        MaxFeatures
        MaxVal
        MinVal
        NumFrames
        QuantizationLevels
        SmoothingRadius
        UpdateBackgroundModel
    end

    methods
        function this = BackgroundSubtractorGMG(varargin)
            %BACKGROUNDSUBTRACTORMOG  BackgroundSubtractorGMG constructor
            %
            %    bs = cv.BackgroundSubtractorGMG()
            %    bs = cv.BackgroundSubtractorGMG('OptionName', optionValue, ...)
            %
            % ## Options
            % * __InitializationFrames__ number of frames used to initialize
            %         the background models. default 120
            % * __DecisionThreshold__ Threshold value, above which it is marked
            %         foreground, else background. default 0.8
            %
            % Default constructor sets all parameters to default values.
            %
            % See also cv.BackgroundSubtractorGMG
            %
            this.id = BackgroundSubtractorGMG_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.BackgroundSubtractorGMG
            %
            BackgroundSubtractorGMG_(this.id, 'delete');
        end

        function fgmask = apply(this, im, varargin)
            %APPLY  Computes a foreground mask
            %
            %    fgmask = bs.apply(im, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __im__ Next video frame.
            %
            % ## Output
            % * __results__ The output foreground mask as an 8-bit binary image.
            %
            % ## Options
            % * __LearningRate__ default -1.
            %
            % See also cv.BackgroundSubtractorGMG
            %
            fgmask = BackgroundSubtractorGMG_(this.id, 'apply', im, varargin{:});
        end

        function im = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a foreground mask
            %
            %    im = bs.getBackgroundImage()
            %
            %
            % ## Output
            % * __im__ The output background image.
            %
            % See also cv.BackgroundSubtractorGMG
            %
            im = BackgroundSubtractorGMG_(this.id, 'getBackgroundImage');
        end

        function value = get.BackgroundPrior(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'BackgroundPrior');
        end
        function set.BackgroundPrior(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'BackgroundPrior', value);
        end

        function value = get.DecisionThreshold(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'DecisionThreshold');
        end
        function set.DecisionThreshold(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'DecisionThreshold', value);
        end

        function value = get.DefaultLearningRate(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'DefaultLearningRate');
        end
        function set.DefaultLearningRate(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'DefaultLearningRate', value);
        end

        function value = get.MaxFeatures(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'MaxFeatures');
        end
        function set.MaxFeatures(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'MaxFeatures', value);
        end

        function value = get.MaxVal(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'MaxVal');
        end
        function set.MaxVal(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'MaxVal', value);
        end

        function value = get.MinVal(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'MinVal');
        end
        function set.MinVal(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'MinVal', value);
        end

        function value = get.NumFrames(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'NumFrames');
        end
        function set.NumFrames(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'NumFrames', value);
        end

        function value = get.QuantizationLevels(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'QuantizationLevels');
        end
        function set.QuantizationLevels(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'QuantizationLevels', value);
        end

        function value = get.SmoothingRadius(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'SmoothingRadius');
        end
        function set.SmoothingRadius(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'SmoothingRadius', value);
        end

        function value = get.UpdateBackgroundModel(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'UpdateBackgroundModel');
        end
        function set.UpdateBackgroundModel(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'UpdateBackgroundModel', value);
        end
    end

end
