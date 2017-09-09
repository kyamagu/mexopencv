classdef BackgroundSubtractorGMG < handle
    %BACKGROUNDSUBTRACTORGMG  Background Subtractor module
    %
    % Background Subtractor module based on the algorithm given in [Gold2012].
    %
    % Takes a series of images and returns a sequence of mask `uint8` images
    % of the same size, where 255 indicates Foreground and 0 represents
    % Background. This class implements an algorithm described in [Gold2012].
    %
    % This algorithm combines statistical background image estimation and
    % per-pixel Bayesian segmentation. It was introduced by [Gold2012]. As per
    % the paper, the system ran a successful interactive audio art
    % installation called "Are We There Yet?" in 2011 at the Contemporary
    % Jewish Museum in San Francisco, California.
    %
    % It uses first few (120 by default) frames for background modelling. It
    % employs probabilistic foreground segmentation algorithm that identifies
    % possible foreground objects using Bayesian inference. The estimates are
    % adaptive; newer observations are more heavily weighted than old
    % observations to accommodate variable illumination. Several morphological
    % filtering operations like closing and opening are done to remove
    % unwanted noise. You will get a black window during first few frames.
    %
    % ## References
    % [Gold2012]:
    % > Andrew B Godbehere, Akihiro Matsukawa, and Ken Goldberg. "Visual
    % > Tracking of Human Visitors under Variable-Lighting Conditions for a
    % > Responsive Audio Art Installation". In American Control Conference
    % > (ACC), Montreal, 2012, pages 4305-4312. IEEE, June 2012.
    %
    % See also: cv.BackgroundSubtractorGMG.BackgroundSubtractorGMG,
    %  cv.BackgroundSubtractorGMG.apply,
    %  cv.BackgroundSubtractorGMG.getBackgroundImage
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Total number of distinct colors to maintain in histogram.
        MaxFeatures
        % The learning rate of the algorithm.
        % It lies between 0.0 and 1.0. It determines how quickly features are
        % "forgotten" from histograms.
        DefaultLearningRate
        % The number of frames used to initialize background model.
        NumFrames
        % The parameter used for quantization of color-space.
        % It is the number of discrete levels in each channel to be used in
        % histograms.
        QuantizationLevels
        % The prior probability that each individual pixel is a background
        % pixel.
        BackgroundPrior
        % The kernel radius, in pixels, used for morphological operations for
        % cleaning up FG image.
        SmoothingRadius
        % The value of decision threshold.
        % Decision value is the value above which pixel is determined to be FG.
        DecisionThreshold
        % The status of background model update.
        UpdateBackgroundModel
        % The minimum value taken on by pixels in image sequence. Usually 0.
        MinVal
        % The maximum value taken on by pixels in image sequence.
        % e.g. 1.0 or 255.
        MaxVal
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorGMG(varargin)
            %BACKGROUNDSUBTRACTORGMG  Creates a GMG Background Subtractor
            %
            %     bs = cv.BackgroundSubtractorGMG()
            %     bs = cv.BackgroundSubtractorGMG('OptionName', optionValue, ...)
            %
            % ## Options
            % * __InitializationFrames__ number of frames used to initialize
            %   the background models. default 120
            % * __DecisionThreshold__ Threshold value, above which it is
            %   marked foreground, else background. default 0.8
            %
            % Default constructor sets all parameters to default values.
            %
            % See also: cv.BackgroundSubtractorGMG
            %
            this.id = BackgroundSubtractorGMG_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     bs.delete()
            %
            % See also: cv.BackgroundSubtractorGMG
            %
            if isempty(this.id), return; end
            BackgroundSubtractorGMG_(this.id, 'delete');
        end

        function fgmask = apply(this, im, varargin)
            %APPLY  Updates the background model and computes the foreground mask
            %
            %     fgmask = bs.apply(im)
            %     fgmask = bs.apply(im, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __im__ Next video frame.
            %
            % ## Output
            % * __fgmask__ The output foreground mask as an 8-bit binary image
            %   (0 for background, 255 for foregound).
            %
            % ## Options
            % * __LearningRate__ The value between 0 and 1 that indicates how
            %   fast the background model is learnt. Negative parameter value
            %   makes the algorithm to use some automatically chosen learning
            %   rate. 0 means that the background model is not updated at all,
            %   1 means that the background model is completely reinitialized
            %   from the last frame. default -1
            %
            % Performs single-frame background subtraction and builds up a
            % statistical background image model.
            %
            % See also: cv.BackgroundSubtractorGMG.getBackgroundImage
            %
            fgmask = BackgroundSubtractorGMG_(this.id, 'apply', im, varargin{:});
        end

        function bgImg = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a background image
            %
            %     bgImg = bs.getBackgroundImage()
            %
            % ## Output
            % * __bgImg__ The output background image.
            %
            % ### Note
            % Method not implemented for this class, returns empty.
            %
            % See also: cv.BackgroundSubtractorGMG.apply
            %
            bgImg = BackgroundSubtractorGMG_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BackgroundSubtractorGMG.empty
            %
            BackgroundSubtractorGMG_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.BackgroundSubtractorGMG.clear
            %
            b = BackgroundSubtractorGMG_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.BackgroundSubtractorGMG.save, cv.BackgroundSubtractorGMG.load
            %
            name = BackgroundSubtractorGMG_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.BackgroundSubtractorGMG.load
            %
            BackgroundSubtractorGMG_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.BackgroundSubtractorGMG.save
            %
            BackgroundSubtractorGMG_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.MaxFeatures(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'MaxFeatures');
        end
        function set.MaxFeatures(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'MaxFeatures', value);
        end

        function value = get.DefaultLearningRate(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'DefaultLearningRate');
        end
        function set.DefaultLearningRate(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'DefaultLearningRate', value);
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

        function value = get.BackgroundPrior(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'BackgroundPrior');
        end
        function set.BackgroundPrior(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'BackgroundPrior', value);
        end

        function value = get.SmoothingRadius(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'SmoothingRadius');
        end
        function set.SmoothingRadius(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'SmoothingRadius', value);
        end

        function value = get.DecisionThreshold(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'DecisionThreshold');
        end
        function set.DecisionThreshold(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'DecisionThreshold', value);
        end

        function value = get.UpdateBackgroundModel(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'UpdateBackgroundModel');
        end
        function set.UpdateBackgroundModel(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'UpdateBackgroundModel', value);
        end

        function value = get.MinVal(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'MinVal');
        end
        function set.MinVal(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'MinVal', value);
        end

        function value = get.MaxVal(this)
            value = BackgroundSubtractorGMG_(this.id, 'get', 'MaxVal');
        end
        function set.MaxVal(this, value)
            BackgroundSubtractorGMG_(this.id, 'set', 'MaxVal', value);
        end
    end

end
