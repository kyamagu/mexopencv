classdef BackgroundSubtractorGSOC < handle
    %BACKGROUNDSUBTRACTORGSOC  Background Subtraction implemented during GSOC
    %
    % Implementation of the different (compared to cv.BackgroundSubtractorLSBP)
    % yet better algorithm which is called GSOC, as it was implemented during
    % GSOC and was not originated from any paper.
    %
    % This algorithm demonstrates better performance on CDnet 2014 dataset
    % compared to other algorithms in OpenCV.
    %
    % See also: cv.BackgroundSubtractorGSOC.BackgroundSubtractorGSOC,
    %  cv.BackgroundSubtractorGSOC.apply,
    %  cv.BackgroundSubtractorGSOC.getBackgroundImage
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorGSOC(varargin)
            %BACKGROUNDSUBTRACTORGSOC  Creates a GSOC Background Subtractor
            %
            %     bs = cv.BackgroundSubtractorGSOC()
            %     bs = cv.BackgroundSubtractorGSOC('OptionName', optionValue, ...)
            %
            % ## Options
            % * __MotionCompensation__ Whether to use camera motion
            %   compensation. One of:
            %   * __None__ (default)
            %   * __LK__
            % * __NSamples__ Number of samples to maintain at each point of
            %   the frame. default 20
            % * __ReplaceRate__ Probability of replacing the old sample, i.e
            %   how fast the model will update itself. default 0.003
            % * __PropagationRate__ Probability of propagating to neighbors.
            %   default 0.01
            % * __HitsThreshold__ How many positives the sample must get
            %   before it will be considered as a possible replacement.
            %   default 32
            % * __Alpha__ Scale coefficient for threshold. default 0.01
            % * __Beta__ Bias coefficient for threshold. default 0.0022
            % * __BlinkingSupressionDecay__ Blinking supression decay factor.
            %   default 0.1
            % * __BlinkingSupressionMultiplier__ Blinking supression
            %   multiplier. default 0.1
            % * __NoiseRemovalThresholdFacBG__ Strength of the noise removal
            %   for background points. default 0.0004
            % * __NoiseRemovalThresholdFacFG__ Strength of the noise removal
            %   for foreground points. default 0.0008
            %
            % See also: cv.BackgroundSubtractorGSOC
            %
            this.id = BackgroundSubtractorGSOC_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     bs.delete()
            %
            % See also: cv.BackgroundSubtractorGSOC
            %
            if isempty(this.id), return; end
            BackgroundSubtractorGSOC_(this.id, 'delete');
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
            % See also: cv.BackgroundSubtractorGSOC.getBackgroundImage
            %
            fgmask = BackgroundSubtractorGSOC_(this.id, 'apply', im, varargin{:});
        end

        function bgImg = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a background image
            %
            %     bgImg = bs.getBackgroundImage()
            %
            % ## Output
            % * __bgImg__ The output background image.
            %
            % See also: cv.BackgroundSubtractorGSOC.apply
            %
            bgImg = BackgroundSubtractorGSOC_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BackgroundSubtractorGSOC.empty
            %
            BackgroundSubtractorGSOC_(this.id, 'clear');
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
            % See also: cv.BackgroundSubtractorGSOC.clear
            %
            b = BackgroundSubtractorGSOC_(this.id, 'empty');
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
            % See also: cv.BackgroundSubtractorGSOC.save,
            %  cv.BackgroundSubtractorGSOC.load
            %
            name = BackgroundSubtractorGSOC_(this.id, 'getDefaultName');
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
            % See also: cv.BackgroundSubtractorGSOC.load
            %
            BackgroundSubtractorGSOC_(this.id, 'save', filename);
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
            % See also: cv.BackgroundSubtractorGSOC.save
            %
            BackgroundSubtractorGSOC_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

end
