classdef BackgroundSubtractorMOG < handle
    %BACKGROUNDSUBTRACTORMOG  Gaussian Mixture-based Backbround/Foreground Segmentation Algorithm
    %
    % The class implements the algorithm described in:
    %
    % P. KadewTraKuPong and R. Bowden,
    % An improved adaptive background mixture model for real-time tracking with
    % shadow detection, Proc. 2nd European Workshp on Advanced Video-Based
    % Surveillance Systems, 2001.
    %
    % http://personal.ee.surrey.ac.uk/Personal/R.Bowden/publications/avbs01/avbs01.pdf
    %
    % See also cv.BackgroundSubtractorMOG.BackgroundSubtractorMOG
    % cv.BackgroundSubtractorMOG.apply
    % cv.BackgroundSubtractorMOG.getBackgroundImage
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        History         % History
        NMixtures       % Number of mixture components
        BackgroundRatio % Ratio of the background
        NoiseSigma      % Sigma of noise
    end

    methods
        function this = BackgroundSubtractorMOG(varargin)
            %BACKGROUNDSUBTRACTORMOG  BackgroundSubtractorMOG constructor
            %
            %    bs = cv.BackgroundSubtractorMOG()
            %    bs = cv.BackgroundSubtractorMOG('OptionName', optionValue, ...)
            %
            % ## Options
            % * __History__ Length of the history. default 200
            % * __NMixtures__ Number of Gaussian mixtures. default 5
            % * __BackgroundRatio__ Background ratio. default 0.7
            % * __NoiseSigma__ Noise strength (standard deviation of the
            %         brightness or each color channel). `0` means some
            %         automatic value. default 0
            %
            % Default constructor sets all parameters to default values.
            %
            % See also cv.BackgroundSubtractorMOG
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
            % See also cv.BackgroundSubtractorMOG
            %
            fgmask = BackgroundSubtractorMOG_(this.id, 'apply', im, varargin{:});
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
            % See also cv.BackgroundSubtractorMOG
            %
            im = BackgroundSubtractorMOG_(this.id, 'getBackgroundImage');
        end

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
