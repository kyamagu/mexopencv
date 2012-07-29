classdef BackgroundSubtractorMOG2 < handle
    %BACKGROUNDSUBTRACTORMOG2  Gaussian Mixture-based Backbround/Foreground Segmentation Algorithm
    %
    % The class implements the Gaussian mixture model background subtraction
    % described in:
    %
    % Z.Zivkovic
    % Improved adaptive Gausian mixture model for background subtraction,
    % International Conference Pattern Recognition, UK, August, 2004,
    % http://www.zoranz.net/Publications/zivkovic2004ICPR.pdf.
    %
    % The code is very fast and performs also shadow detection. Number of
    % Gausssian components is adapted per pixel.
    %
    % Z.Zivkovic, F. van der Heijden,
    % Efficient Adaptive Density Estimapion per Image Pixel for the Task of
    % Background Subtraction,
    % Pattern Recognition Letters, vol. 27, no. 7, pages 773-780, 2006.
    %
    % The algorithm similar to the standard Stauffer&Grimson algorithm with
    % additional selection of the number of the Gaussian components based on:
    %
    % Z.Zivkovic, F.van der Heijden,
    % Recursive unsupervised learning of finite mixture models,
    % IEEE Trans. on Pattern Analysis and Machine Intelligence, vol.26, no.5, pages 651-656, 2004.
    %
    % See also cv.BackgroundSubtractorMOG2.BackgroundSubtractorMOG2
    % cv.BackgroundSubtractorMOG2.apply
    % cv.BackgroundSubtractorMOG2.getBackgroundImage
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        frameSize        % Size of the frame (not accessible >= 2.4.0)
        nframes          % Number of frames  (not accessible >= 2.4.0)
        history          % History
        nmixtures        % Number of mixture components (not accessible >= 2.4.0)
        varThreshold     % Threshold value
        backgroundRatio  % Ratio of the background (not accessible >= 2.4.0)
    end

    methods
        function this = BackgroundSubtractorMOG2(varargin)
            %BACKGROUNDSUBTRACTORMOG  BackgroundSubtractorMOG2 constructor
            %
            %    bs = cv.BackgroundSubtractorMOG2()
            %    bs = cv.BackgroundSubtractorMOG2(history, varThreshold, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __history__ Length of the history.
            % * __varThreshold__ Threshold on the squared Mahalanobis distance to
            %        decide whether it is well described by the background
            %        model. This parameter does not affect the background
            %        update. A typical value could be 4 sigma, that is,
            %        varThreshold=4*4=16.
            %
            % ## Options
            % * __BShadowDetection__ Parameter defining whether shadow detection
            %        should be enabled (true or false).
            %
            % See also cv.BackgroundSubtractorMOG2
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
            %    fgmask = bs.apply(im, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __im__ Next video frame.
            %
            % ## Output
            % * __results__ The output foreground mask as an 8-bit binary image.
            %
            % ## Options
            % * __LearningRate__ default 0.
            %
            % See also cv.BackgroundSubtractorMOG2
            %
            fgmask = BackgroundSubtractorMOG2_(this.id, 'apply', im, varargin{:});
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
            % See also cv.BackgroundSubtractorMOG2
            %
            im = BackgroundSubtractorMOG2_(this.id, 'getBackgroundImage');
        end

        function value = get.frameSize(this)
            value = BackgroundSubtractorMOG2_(this.id, 'frameSize');
        end

        function set.frameSize(this, value)
            BackgroundSubtractorMOG2_(this.id, 'frameSize', value);
        end

        function value = get.nframes(this)
            value = BackgroundSubtractorMOG2_(this.id, 'nframes');
        end

        function set.nframes(this, value)
            BackgroundSubtractorMOG2_(this.id, 'nframes', value);
        end

        function value = get.history(this)
            value = BackgroundSubtractorMOG2_(this.id, 'history');
        end

        function set.history(this, value)
            BackgroundSubtractorMOG2_(this.id, 'history', value);
        end

        function value = get.nmixtures(this)
            value = BackgroundSubtractorMOG2_(this.id, 'nmixtures');
        end

        function set.nmixtures(this, value)
            BackgroundSubtractorMOG2_(this.id, 'nmixtures', value);
        end

        function value = get.varThreshold(this)
            value = BackgroundSubtractorMOG2_(this.id, 'varThreshold');
        end

        function set.varThreshold(this, value)
            BackgroundSubtractorMOG2_(this.id, 'varThreshold', value);
        end

        function value = get.backgroundRatio(this)
            value = BackgroundSubtractorMOG2_(this.id, 'backgroundRatio');
        end

        function set.backgroundRatio(this, value)
            BackgroundSubtractorMOG2_(this.id, 'backgroundRatio', value);
        end
    end

end
