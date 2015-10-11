classdef BackgroundSubtractorMOG2 < handle
    %BACKGROUNDSUBTRACTORMOG2  Gaussian Mixture-based Backbround/Foreground Segmentation Algorithm
    %
    % The class implements the Gaussian mixture model background subtraction
    % described in [Zivkovic2004] and [Zivkovic2006].
    %
    % The code is very fast and performs also shadow detection. Number of
    % Gausssian components is adapted per pixel.
    %
    % The algorithm similar to the standard Stauffer&Grimson algorithm with
    % additional selection of the number of the Gaussian components based on
    % [Zivkovic04recursiveunsupervised].
    %
    % ## References
    % [Zivkovic2004]:
    % > Zoran Zivkovic. "Improved adaptive gaussian mixture model for
    % > background subtraction". In Pattern Recognition, 2004. ICPR 2004.
    % > Proceedings of the 17th International Conference on, volume 2,
    % > pages 28-31. IEEE, 2004.
    % > http://www.zoranz.net/Publications/zivkovic2004ICPR.pdf.
    %
    % [Zivkovic2006]:
    % > Zoran Zivkovic and Ferdinand van der Heijden. "Efficient adaptive
    % > density estimation per image pixel for the task of background
    % > subtraction". Pattern recognition letters, 27(7):773-780, 2006.
    %
    % [Zivkovic04recursiveunsupervised]:
    % > Zoran Zivkovic and Ferdinand van der Heijden, "Recursive unsupervised
    % > learning of finite mixture models", IEEE Trans. on Pattern Analysis
    % > and Machine Intelligence, vol.26, no.5, pages 651-656, 2004.
    %
    % [Prati03detectingmoving]:
    % > Andrea Prati, Ivana Mikic, Mohan M. Trivedi, Rita Cucchiara.
    % > "Detecting Moving Shadows: Algorithms and Evaluation", IEEE PAMI, 2003.
    %
    % See also: cv.BackgroundSubtractorMOG2.BackgroundSubtractorMOG2,
    %  cv.BackgroundSubtractorMOG2.apply,
    %  cv.BackgroundSubtractorMOG2.getBackgroundImage,
    %  vision.ForegroundDetector
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % The number of last frames that affect the background model.
        History
        % The number of gaussian components in the background model.
        % The model needs to be reinitalized to reserve memory.
        NMixtures
        % The variance threshold for the pixel-model match.
        % The main threshold on the squared Mahalanobis distance to decide if
        % the sample is well described by the background model or not. Related
        % to `Cthr` from the paper.
        VarThreshold
        % The "background ratio" parameter of the algorithm.
        % If a foreground pixel keeps semi-constant value for about
        % `BackgroundRatio * History` frames, it's considered background and
        % added to the model as a center of a new component. It corresponds to
        % `TB` parameter in the paper.
        BackgroundRatio
        % The complexity reduction threshold.
        % This parameter defines the number of samples needed to accept to
        % prove the component exists. `CT=0.05` is a default value for all the
        % samples. By setting `CT=0` you get an algorithm very similar to the
        % standard Stauffer&Grimson algorithm.
        ComplexityReductionThreshold
        % The shadow detection flag.
        % If true, the algorithm detects shadows and marks them. See
        % cv.BackgroundSubtractorMOG2.BackgroundSubtractorMOG2 for details.
        DetectShadows
        % The shadow threshold.
        % A shadow is detected if pixel is a darker version of the background.
        % The shadow threshold (Tau in the paper) is a threshold defining how
        % much darker the shadow can be. Tau=0.5 means that if a pixel is more
        % than twice darker then it is not shadow.
        % See [Prati03detectingmoving].
        ShadowThreshold
        % The shadow value.
        % Shadow value is the value used to mark shadows in the foreground
        % mask. Default value is 127. Value 0 in the mask always means
        % background, 255 means foreground.
        ShadowValue
        % The initial variance of each gaussian component.
        VarInit
        VarMax
        VarMin
        % The variance threshold for the pixel-model match used for new
        % mixture component generation.
        % Threshold for the squared Mahalanobis distance that helps decide
        % when a sample is close to the existing components (corresponds to
        % `Tg` in the paper). If a pixel is not close to any component, it is
        % considered foreground or added as a new component.
        % `3 sigma => Tg=3*3=9` is default. A smaller `Tg` value generates
        % more components. A higher `Tg` value may result in a small number of
        % components but they can grow too large.
        VarThresholdGen
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorMOG2(varargin)
            %BACKGROUNDSUBTRACTORMOG2  Creates MOG2 Background Subtractor
            %
            %    bs = cv.BackgroundSubtractorMOG2()
            %    bs = cv.BackgroundSubtractorMOG2('OptionName', optionValue, ...)
            %
            % ## Options
            % * __History__ Length of the history. default 500
            % * __VarThreshold__ Threshold on the squared Mahalanobis distance
            %       between the pixel and the model to decide whether a pixel
            %       is well described by the background model. This parameter
            %       does not affect the background update. default 16
            % * __DetectShadows__ If true, the algorithm will detect shadows
            %       and mark them. It decreases the speed a bit, so if you do
            %       not need this feature, set the parameter to false.
            %       default true
            %
            % See also: cv.BackgroundSubtractorMOG2
            %
            this.id = BackgroundSubtractorMOG2_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.BackgroundSubtractorMOG2
            %
            BackgroundSubtractorMOG2_(this.id, 'delete');
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
            % See also: cv.BackgroundSubtractorMOG2.getBackgroundImage
            %
            fgmask = BackgroundSubtractorMOG2_(this.id, 'apply', im, varargin{:});
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
            % See also: cv.BackgroundSubtractorMOG2.apply
            %
            bgImg = BackgroundSubtractorMOG2_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.BackgroundSubtractorMOG2.empty
            %
            BackgroundSubtractorMOG2_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty.
            %
            %    obj.empty()
            %
            % (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.BackgroundSubtractorMOG2.clear
            %
            b = BackgroundSubtractorMOG2_(this.id, 'empty');
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
            % See also: cv.BackgroundSubtractorMOG2.save, cv.BackgroundSubtractorMOG2.load
            %
            name = BackgroundSubtractorMOG2_(this.id, 'getDefaultName');
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
            % See also: cv.BackgroundSubtractorMOG2.load
            %
            BackgroundSubtractorMOG2_(this.id, 'save', filename);
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
            % See also: cv.BackgroundSubtractorMOG2.save
            %
            BackgroundSubtractorMOG2_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.History(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'History');
        end
        function set.History(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'History', value);
        end

        function value = get.NMixtures(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'NMixtures');
        end
        function set.NMixtures(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'NMixtures', value);
        end

        function value = get.VarThreshold(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'VarThreshold');
        end
        function set.VarThreshold(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'VarThreshold', value);
        end

        function value = get.BackgroundRatio(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'BackgroundRatio');
        end
        function set.BackgroundRatio(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'BackgroundRatio', value);
        end

        function value = get.ComplexityReductionThreshold(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'ComplexityReductionThreshold');
        end
        function set.ComplexityReductionThreshold(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'ComplexityReductionThreshold', value);
        end

        function value = get.DetectShadows(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'DetectShadows');
        end
        function set.DetectShadows(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'DetectShadows', value);
        end

        function value = get.ShadowThreshold(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'ShadowThreshold');
        end
        function set.ShadowThreshold(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'ShadowThreshold', value);
        end

        function value = get.ShadowValue(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'ShadowValue');
        end
        function set.ShadowValue(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'ShadowValue', value);
        end

        function value = get.VarInit(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'VarInit');
        end
        function set.VarInit(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'VarInit', value);
        end

        function value = get.VarMax(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'VarMax');
        end
        function set.VarMax(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'VarMax', value);
        end

        function value = get.VarMin(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'VarMin');
        end
        function set.VarMin(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'VarMin', value);
        end

        function value = get.VarThresholdGen(this)
            value = BackgroundSubtractorMOG2_(this.id, 'get', 'VarThresholdGen');
        end
        function set.VarThresholdGen(this, value)
            BackgroundSubtractorMOG2_(this.id, 'set', 'VarThresholdGen', value);
        end
    end

end
