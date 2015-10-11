classdef BackgroundSubtractorMOG < handle
    %BACKGROUNDSUBTRACTORMOG  Gaussian Mixture-based Backbround/Foreground Segmentation Algorithm
    %
    % The class implements the algorithm described in [KB2001].
    %
    % ## References
    % [KB2001]:
    % > Pakorn KaewTraKulPong and Richard Bowden. "An improved adaptive
    % > background mixture model for real-time tracking with shadow detection".
    % > In Video-Based Surveillance Systems, pages 135-144. Springer, 2002.
    % > http://personal.ee.surrey.ac.uk/Personal/R.Bowden/publications/avbs01/avbs01.pdf
    %
    % See also cv.BackgroundSubtractorMOG.BackgroundSubtractorMOG,
    %  cv.BackgroundSubtractorMOG.apply,
    %  cv.BackgroundSubtractorMOG.getBackgroundImage
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
        % The "background ratio" parameter of the algorithm.
        % If a foreground pixel keeps semi-constant value for about
        % `BackgroundRatio * History` frames, it's considered background and
        % added to the model as a center of a new component. It corresponds to
        % `TB` parameter in the paper.
        BackgroundRatio
        % Sigma of noise
        NoiseSigma
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorMOG(varargin)
            %BACKGROUNDSUBTRACTORMOG  Creates mixture-of-gaussian background subtractor
            %
            %    bs = cv.BackgroundSubtractorMOG()
            %    bs = cv.BackgroundSubtractorMOG('OptionName', optionValue, ...)
            %
            % ## Options
            % * __History__ Length of the history. default 200
            % * __NMixtures__ Number of Gaussian mixtures. default 5
            % * __BackgroundRatio__ Background ratio. default 0.7
            % * __NoiseSigma__ Noise strength (standard deviation of the
            %       brightness or each color channel). 0 means some automatic
            %       value. default 0
            %
            % Default constructor sets all parameters to default values.
            %
            % See also: cv.BackgroundSubtractorMOG
            %
            this.id = BackgroundSubtractorMOG_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.BackgroundSubtractorMOG
            %
            BackgroundSubtractorMOG_(this.id, 'delete');
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
            % See also: cv.BackgroundSubtractorMOG.getBackgroundImage
            %
            fgmask = BackgroundSubtractorMOG_(this.id, 'apply', im, varargin{:});
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
            % See also: cv.BackgroundSubtractorMOG.apply
            %
            bgImg = BackgroundSubtractorMOG_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.BackgroundSubtractorMOG.empty
            %
            BackgroundSubtractorMOG_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty.
            %
            %    obj.empty()
            %
            % (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.BackgroundSubtractorMOG.clear
            %
            b = BackgroundSubtractorMOG_(this.id, 'empty');
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
            % See also: cv.BackgroundSubtractorMOG.save, cv.BackgroundSubtractorMOG.load
            %
            name = BackgroundSubtractorMOG_(this.id, 'getDefaultName');
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
            % See also: cv.BackgroundSubtractorMOG.load
            %
            BackgroundSubtractorMOG_(this.id, 'save', filename);
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
            % See also: cv.BackgroundSubtractorMOG.save
            %
            BackgroundSubtractorMOG_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.History(this)
            value = BackgroundSubtractorMOG_(this.id, 'get', 'History');
        end
        function set.History(this, value)
            BackgroundSubtractorMOG_(this.id, 'set', 'History', value);
        end

        function value = get.NMixtures(this)
            value = BackgroundSubtractorMOG_(this.id, 'get', 'NMixtures');
        end
        function set.NMixtures(this, value)
            BackgroundSubtractorMOG_(this.id, 'set', 'NMixtures', value);
        end

        function value = get.BackgroundRatio(this)
            value = BackgroundSubtractorMOG_(this.id, 'get', 'BackgroundRatio');
        end
        function set.BackgroundRatio(this, value)
            BackgroundSubtractorMOG_(this.id, 'set', 'BackgroundRatio', value);
        end

        function value = get.NoiseSigma(this)
            value = BackgroundSubtractorMOG_(this.id, 'get', 'NoiseSigma');
        end
        function set.NoiseSigma(this, value)
            BackgroundSubtractorMOG_(this.id, 'set', 'NoiseSigma', value);
        end
    end

end
