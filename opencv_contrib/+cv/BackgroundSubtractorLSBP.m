classdef BackgroundSubtractorLSBP < handle
    %BACKGROUNDSUBTRACTORLSBP  Background Subtraction using Local SVD Binary Pattern
    %
    % More details about the algorithm can be found at [LGuo2016].
    %
    % It is based on LSBP feature descriptors and achieves state-of-the-art
    % performance on the CDnet 2012 dataset. LSBP descriptors are particularly
    % good in regions with illumination variation, noise and shadows. So, this
    % algorithm has better performance in this kind of regions.
    %
    % After extraction of LSBP descriptors, the algorithm processes frames
    % pixel-wise (i.e independently). Thus the implementation is parallelized
    % and fast enough for real-time processing.
    %
    % ## References
    % [LGuo2016]:
    % > L. Guo, D. Xu, and Z. Qiang. "Background Subtraction using Local SVD
    % > Binary Pattern". In 2016 IEEE Conference on Computer Vision and
    % > Pattern Recognition Workshops (CVPRW), pages 1159-1167, June 2016.
    % > [PDF](http://www.cv-foundation.org/openaccess/content_cvpr_2016_workshops/w24/papers/Guo_Background_Subtraction_Using_CVPR_2016_paper.pdf)
    %
    % See also: cv.BackgroundSubtractorLSBP.BackgroundSubtractorLSBP,
    %  cv.BackgroundSubtractorLSBP.apply,
    %  cv.BackgroundSubtractorLSBP.getBackgroundImage
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% BackgroundSubtractor
    methods
        function this = BackgroundSubtractorLSBP(varargin)
            %BACKGROUNDSUBTRACTORLSBP  Creates a LSBP Background Subtractor
            %
            %     bs = cv.BackgroundSubtractorLSBP()
            %     bs = cv.BackgroundSubtractorLSBP('OptionName', optionValue, ...)
            %
            % ## Options
            % * __MotionCompensation__ Whether to use camera motion
            %   compensation. One of:
            %   * __None__ (default)
            %   * __LK__
            % * __NSamples__ Number of samples to maintain at each point of
            %   the frame. default 20
            % * __LSBPRadius__ LSBP descriptor radius. default 16
            % * __TLower__ Lower bound for T-values. See [LGuo2016] for
            %   details. default 2.0
            % * __TUpper__ Upper bound for T-values. See [LGuo2016] for
            %   details. default 32.0
            % * __TInc__ Increase step for T-values. See [LGuo2016] for
            %   details. default 1.0
            % * __TDec__ Decrease step for T-values. See [LGuo2016] for
            %   details. default 0.05
            % * __RScale__ Scale coefficient for threshold values. default 10.0
            % * __RIncDec__ Increase/Decrease step for threshold values.
            %   default 0.005
            % * __NoiseRemovalThresholdFacBG__ Strength of the noise removal
            %   for background points. default 0.0004
            % * __NoiseRemovalThresholdFacFG__ Strength of the noise removal
            %   for foreground points. default 0.0008
            % * __LSBPThreshold__ Threshold for LSBP binary string. default 8
            % * __MinCount__ Minimal number of matches for sample to be
            %   considered as foreground. default 2
            %
            % See also: cv.BackgroundSubtractorLSBP
            %
            this.id = BackgroundSubtractorLSBP_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     bs.delete()
            %
            % See also: cv.BackgroundSubtractorLSBP
            %
            if isempty(this.id), return; end
            BackgroundSubtractorLSBP_(this.id, 'delete');
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
            % See also: cv.BackgroundSubtractorLSBP.getBackgroundImage
            %
            fgmask = BackgroundSubtractorLSBP_(this.id, 'apply', im, varargin{:});
        end

        function bgImg = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a background image
            %
            %     bgImg = bs.getBackgroundImage()
            %
            % ## Output
            % * __bgImg__ The output background image.
            %
            % See also: cv.BackgroundSubtractorLSBP.apply
            %
            bgImg = BackgroundSubtractorLSBP_(this.id, 'getBackgroundImage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BackgroundSubtractorLSBP.empty
            %
            BackgroundSubtractorLSBP_(this.id, 'clear');
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
            % See also: cv.BackgroundSubtractorLSBP.clear
            %
            b = BackgroundSubtractorLSBP_(this.id, 'empty');
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
            % See also: cv.BackgroundSubtractorLSBP.save,
            %  cv.BackgroundSubtractorLSBP.load
            %
            name = BackgroundSubtractorLSBP_(this.id, 'getDefaultName');
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
            % See also: cv.BackgroundSubtractorLSBP.load
            %
            BackgroundSubtractorLSBP_(this.id, 'save', filename);
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
            % See also: cv.BackgroundSubtractorLSBP.save
            %
            BackgroundSubtractorLSBP_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% BackgroundSubtractorLSBPDesc
    methods (Static)
        function desc = computeLSBPDesc(frame, LSBPSamplePoints)
            %COMPUTELSBPDESC  This is for calculation of the LSBP descriptors
            %
            %     desc = cv.BackgroundSubtractorLSBP.computeLSBPDesc(frame, LSBPSamplePoints)
            %
            % ## Input
            % * __frame__ input frame
            % * __LSBPSamplePoints__ 32 sample points
            %
            % ## Output
            % * __desc__ LSBP descriptors
            %
            desc = BackgroundSubtractorLSBP_(0, 'computeLSBPDesc', frame, LSBPSamplePoints);
        end
    end

end
