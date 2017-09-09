classdef BackgroundSubtractorCNT < handle
    %BACKGROUNDSUBTRACTORCNT  Background subtraction based on counting
    %
    % About as fast as cv.BackgroundSubtractorMOG2 on a high end system.
    % More than twice faster than MOG2 on cheap hardware (benchmarked on
    % Raspberry Pi3).
    %
    % Algorithm by:
    % [Sagi Zeevi](https://github.com/sagi-z/BackgroundSubtractorCNT)
    %
    % See also: cv.BackgroundSubtractorCNT.BackgroundSubtractorCNT,
    %  cv.BackgroundSubtractorCNT.apply,
    %  cv.BackgroundSubtractorCNT.getBackgroundImage
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % number of frames with same pixel color to consider stable.
        MinPixelStability
        % maximum allowed credit for a pixel in history.
        MaxPixelStability
        % if we're giving a pixel credit for being stable for a long time.
        UseHistory
        % if we're parallelizing the algorithm.
        IsParallel
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorCNT(varargin)
            %BACKGROUNDSUBTRACTORCNT  Creates a CNT Background Subtractor
            %
            %     bs = cv.BackgroundSubtractorCNT()
            %     bs = cv.BackgroundSubtractorCNT('OptionName', optionValue, ...)
            %
            % ## Options
            % * __MinPixelStability__ number of frames with same pixel color
            %   to consider stable. default 15
            % * __MaxPixelStability__ maximum allowed credit for a pixel in
            %   history. default 15*60
            % * __UseHistory__ determines if we're giving a pixel credit for
            %   being stable for a long time. default true
            % * __IsParallel__ determines if we're parallelizing the algorithm.
            %   default true
            %
            % See also: cv.BackgroundSubtractorCNT
            %
            this.id = BackgroundSubtractorCNT_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     bs.delete()
            %
            % See also: cv.BackgroundSubtractorCNT
            %
            if isempty(this.id), return; end
            BackgroundSubtractorCNT_(this.id, 'delete');
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
            % See also: cv.BackgroundSubtractorCNT.getBackgroundImage
            %
            fgmask = BackgroundSubtractorCNT_(this.id, 'apply', im, varargin{:});
        end

        function bgImg = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a background image
            %
            %     bgImg = bs.getBackgroundImage()
            %
            % ## Output
            % * __bgImg__ The output background image.
            %
            % See also: cv.BackgroundSubtractorCNT.apply
            %
            bgImg = BackgroundSubtractorCNT_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BackgroundSubtractorCNT.empty
            %
            BackgroundSubtractorCNT_(this.id, 'clear');
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
            % See also: cv.BackgroundSubtractorCNT.clear
            %
            b = BackgroundSubtractorCNT_(this.id, 'empty');
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
            % See also: cv.BackgroundSubtractorCNT.save, cv.BackgroundSubtractorCNT.load
            %
            name = BackgroundSubtractorCNT_(this.id, 'getDefaultName');
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
            % See also: cv.BackgroundSubtractorCNT.load
            %
            BackgroundSubtractorCNT_(this.id, 'save', filename);
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
            % See also: cv.BackgroundSubtractorCNT.save
            %
            BackgroundSubtractorCNT_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.MinPixelStability(this)
            value = BackgroundSubtractorCNT_(this.id, 'get', 'MinPixelStability');
        end
        function set.MinPixelStability(this, value)
            BackgroundSubtractorCNT_(this.id, 'set', 'MinPixelStability', value);
        end

        function value = get.MaxPixelStability(this)
            value = BackgroundSubtractorCNT_(this.id, 'get', 'MaxPixelStability');
        end
        function set.MaxPixelStability(this, value)
            BackgroundSubtractorCNT_(this.id, 'set', 'MaxPixelStability', value);
        end

        function value = get.UseHistory(this)
            value = BackgroundSubtractorCNT_(this.id, 'get', 'UseHistory');
        end
        function set.UseHistory(this, value)
            BackgroundSubtractorCNT_(this.id, 'set', 'UseHistory', value);
        end

        function value = get.IsParallel(this)
            value = BackgroundSubtractorCNT_(this.id, 'get', 'IsParallel');
        end
        function set.IsParallel(this, value)
            BackgroundSubtractorCNT_(this.id, 'set', 'IsParallel', value);
        end
    end

end
