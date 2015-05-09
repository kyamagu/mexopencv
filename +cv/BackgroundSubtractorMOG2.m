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
        History          % History
        NMixtures        % Number of mixture components
        VarThreshold     % Threshold value
        BackgroundRatio  % Ratio of the background
        ComplexityReductionThreshold
        DetectShadows
        ShadowThreshold
        ShadowValue
        VarInit
        VarMax
        VarMin
        VarThresholdGen
    end

    methods
        function this = BackgroundSubtractorMOG2(varargin)
            %BACKGROUNDSUBTRACTORMOG  BackgroundSubtractorMOG2 constructor
            %
            %    bs = cv.BackgroundSubtractorMOG2()
            %    bs = cv.BackgroundSubtractorMOG2('OptionName', optionValue, ...)
            %
            % ## Options
            % * __History__ Length of the history. default 500
            % * __VarThreshold__ Threshold on the squared Mahalanobis distance to
            %        decide whether it is well described by the background
            %        model. This parameter does not affect the background
            %        update. A typical value could be 4 sigma, that is,
            %        varThreshold=4*4=16. default 16
            % * __DetectShadows__ If true, the algorithm will detect shadows and
            %        mark them. It decreases the speed a bit, so if you do not
            %        need this feature, set the parameter to false. default true
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
