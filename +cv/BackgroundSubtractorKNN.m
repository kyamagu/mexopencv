classdef BackgroundSubtractorKNN < handle
    %BACKGROUNDSUBTRACTORKNN  K-nearest neigbours based Background/Foreground Segmentation Algorithm
    %
    % The class implements the K-nearest neigbours background subtraction
    % described in [Zivkovic2006]. Very efficient if number of foreground
    % pixels is low.
    %
    % ## References
    % [Zivkovic2006]:
    % > Zoran Zivkovic and Ferdinand van der Heijden. "Efficient adaptive
    % > density estimation per image pixel for the task of background
    % > subtraction". Pattern recognition letters, 27(7):773-780, 2006.
    %
    % [Prati03detectingmoving]:
    % > Andrea Prati, Ivana Mikic, Mohan M. Trivedi, Rita Cucchiara.
    % > "Detecting Moving Shadows: Algorithms and Evaluation", IEEE PAMI, 2003.
    %
    % See also cv.BackgroundSubtractorKNN.BackgroundSubtractorKNN,
    %  cv.BackgroundSubtractorKNN.apply,
    %  cv.BackgroundSubtractorKNN.getBackgroundImage
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % The shadow detection flag.
        % If true, the algorithm detects shadows and marks them. See
        % cv.BackgroundSubtractorKNN.BackgroundSubtractorKNN for details.
        DetectShadows
        % The threshold on the squared distance between the pixel and the
        % sample to decide whether a pixel is close to a data sample.
        Dist2Threshold
        % The number of last frames that affect the background model.
        History
        % The number of neighbours, the k in the kNN.
        % K is the number of samples that need to be within `Dist2Threshold`
        % in order to decide that that pixel is matching the kNN background
        % model.
        KNNSamples
        % The number of data samples in the background model.
        % The model needs to be reinitalized to reserve memory.
        NSamples
        % The shadow threshold.
        % A shadow is detected if pixel is a darker version of the background.
        % The shadow threshold (Tau in the paper) is a threshold defining how
        % much darker the shadow can be. Tau=0.5 means that if a pixel is more
        % than twice darker then it is not shadow.
        % See [Prati03detectingmoving].
        ShadowThreshold
        % Shadow value is the value used to mark shadows in the foreground
        % mask. Default value is 127. Value 0 in the mask always means
        % background, 255 means foreground.
        ShadowValue
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorKNN(varargin)
            %BACKGROUNDSUBTRACTORKNN  Creates KNN Background Subtractor
            %
            %    bs = cv.BackgroundSubtractorKNN()
            %    bs = cv.BackgroundSubtractorKNN('OptionName', optionValue, ...)
            %
            % ## Options
            % * __History__ Length of the history. default 500
            % * __Dist2Threshold__ Threshold on the squared distance between
            %       the pixel and the sample to decide whether a pixel is
            %       close to that sample. This parameter does not affect the
            %       background update. default 400.0
            % * __DetectShadows__ If true, the algorithm will detect shadows
            %       and mark them. It decreases the speed a bit, so if you do
            %       not need this feature, set the parameter to false.
            %       default true
            %
            % See also: cv.BackgroundSubtractorKNN
            %
            this.id = BackgroundSubtractorKNN_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.BackgroundSubtractorKNN
            %
            BackgroundSubtractorKNN_(this.id, 'delete');
        end

        function fgmask = apply(this, im, varargin)
            %APPLY  Updates the background model and computes the foreground mask
            %
            %    fgmask = bs.apply(im)
            %    fgmask = bs.apply(im, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __im__ Next video frame.
            %
            % ## Output
            % * __fgmask__ The output foreground mask as a binary image.
            %
            % ## Options
            % * __LearningRate__ The value between 0 and 1 that indicates how
            %       fast the background model is learnt. Negative parameter
            %       value makes the algorithm to use some automatically chosen
            %       learning rate. 0 means that the background model is not
            %       updated at all, 1 means that the background model is
            %       completely reinitialized from the last frame. default -1
            %
            % See also: cv.BackgroundSubtractorKNN.getBackgroundImage
            %
            fgmask = BackgroundSubtractorKNN_(this.id, 'apply', im, varargin{:});
        end

        function bgImg = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a foreground mask
            %
            %    bgImg = bs.getBackgroundImage()
            %
            % ## Output
            % * __bgImg__ The output background image.
            %
            % ## Note
            % Sometimes the background image can be very blurry, as it contain
            % the average background statistics.
            %
            % See also: cv.BackgroundSubtractorKNN.apply
            %
            bgImg = BackgroundSubtractorKNN_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.BackgroundSubtractorKNN.empty
            %
            BackgroundSubtractorKNN_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty.
            %
            %    obj.empty()
            %
            % (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.BackgroundSubtractorKNN.clear
            %
            b = BackgroundSubtractorKNN_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier.
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.BackgroundSubtractorKNN.save, cv.BackgroundSubtractorKNN.load
            %
            name = BackgroundSubtractorKNN_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file.
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.BackgroundSubtractorKNN.load
            %
            BackgroundSubtractorKNN_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string.
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model.
            %       default false
            %
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.BackgroundSubtractorKNN.save
            %
            BackgroundSubtractorKNN_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.DetectShadows(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'DetectShadows');
        end
        function set.DetectShadows(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'DetectShadows', value);
        end

        function value = get.Dist2Threshold(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'Dist2Threshold');
        end
        function set.Dist2Threshold(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'Dist2Threshold', value);
        end

        function value = get.History(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'History');
        end
        function set.History(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'History', value);
        end

        function value = get.KNNSamples(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'KNNSamples');
        end
        function set.KNNSamples(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'KNNSamples', value);
        end

        function value = get.NSamples(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'NSamples');
        end
        function set.NSamples(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'NSamples', value);
        end

        function value = get.ShadowThreshold(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'ShadowThreshold');
        end
        function set.ShadowThreshold(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'ShadowThreshold', value);
        end

        function value = get.ShadowValue(this)
            value = BackgroundSubtractorKNN_(this.id, 'get', 'ShadowValue');
        end
        function set.ShadowValue(this, value)
            BackgroundSubtractorKNN_(this.id, 'set', 'ShadowValue', value);
        end
    end

end
