classdef BackgroundSubtractorKNN < handle
    %BACKGROUNDSUBTRACTORKNN
    %
    % See also cv.BackgroundSubtractorKNN.BackgroundSubtractorKNN
    % cv.BackgroundSubtractorKNN.apply
    % cv.BackgroundSubtractorKNN.getBackgroundImage
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        DetectShadows
        Dist2Threshold
        History
        KNNSamples
        NSamples
        ShadowThreshold
        ShadowValue
    end

    methods
        function this = BackgroundSubtractorKNN(varargin)
            %BACKGROUNDSUBTRACTORMOG  BackgroundSubtractorKNN constructor
            %
            %    bs = cv.BackgroundSubtractorKNN()
            %    bs = cv.BackgroundSubtractorKNN('OptionName', optionValue, ...)
            %
            % ## Options
            % * __History__ Length of the history. default 500
            % * __Dist2Threshold__ Threshold on the squared distance between the
            %        pixel and the sample to decide whether a pixel is close to
            %        that sample. This parameter does not affect the background
            %        update. default 400.0
            % * __DetectShadows__ If true, the algorithm will detect shadows and
            %        mark them. It decreases the speed a bit, so if you do not
            %        need this feature, set the parameter to false. default true
            %
            % See also cv.BackgroundSubtractorKNN
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
            % See also cv.BackgroundSubtractorKNN
            %
            fgmask = BackgroundSubtractorKNN_(this.id, 'apply', im, varargin{:});
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
            % See also cv.BackgroundSubtractorKNN
            %
            im = BackgroundSubtractorKNN_(this.id, 'getBackgroundImage');
        end

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
