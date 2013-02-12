classdef HOGDescriptor < handle
    %HOGDESCRIPTOR Histogram of Oriented Gaussian descriptor
    %
    % The descriptor of:
    % > Navneet Dalal and Bill Triggs. Histogram of oriented gradients for
    % > human detection. 2005.
    %
    % The basic usage is the following:
    %
    %    hog = cv.HOGDescriptor();
    %    descriptors = hog.compute(im);
    %
    % If you need to compute descriptors for a set of certain keypoints, use
    % 'Locations' option:
    %
    %    keypoints = cv.FAST(im);
    %    descriptors = hog.compute(im, 'Locations', {keypoints.pt});
    %
    % The built-in people detector is accessible through:
    %
    %    hog.setSVMDetector('Default');
    %    boxes = hog.detectMultiScale(im);
    %
    % See also cv.HOGDescriptor.HOGDescriptor cv.HOGDescriptor.compute
    % cv.HOGDescriptor.detect cv.HOGDescriptor.detectMultiScale
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        WinSize           % Window size
        BlockSize         % Block size
        BlockStride       % Block stride of a grid
        CellSize          % Cell size of a grid
        NBins             % Number of bins
        DerivAperture     % Derivative of aperture
        WinSigma          % Window sigma
        HistogramNormType % Histogram normalization method
        L2HysThreshold    % L2 Hysterisis threshold
        GammaCorrection   % Gamma correction
        NLevels           % Number of levels
    end

    properties (Dependent, Hidden, SetAccess = private)
        SvmDetector       % Coefficients for the linear SVM classifier
    end

    methods
        function this = HOGDescriptor(varargin)
            %HOGDESCRIPTOR  Create or load a new HOG descriptor object
            %
            %    hog = cv.HOGDescriptor()
            %    hog = cv.HOGDescriptor(filename)
            %    hog = cv.HOGDescriptor('PropertyName', propertyValue, ...)
            %
            % ## Input
            % * __filename__ Filename of existing HOG descriptor config to load from
            %
            % ## Output
            % * __hog_ HOG descriptor object
            %
            % ## Options
            % * __WinSize__ Detection window size. Align to block size and block
            %       stride. default [64,128]
            % * __BlockSize__ Block size in pixels. Align to cell size.
            %       default [16,16]
            % * __BlockStride__ Block stride. It must be a multiple of cell
            %       size. default [8,8]
            % * __CellSize__ Cell size. default [8,8]
            % * __NBins__ Number of bins. default 9
            % * __DerivAperture__ default 1
            % * __WinSigma__ Gaussian smoothing window parameter. default -1
            %       (corresponds to `sum(BlockSize)/8`)
            % * __HistogramNormType__ default 'L2Hys'
            % * __L2HysThreshold__ L2-Hys normalization method shrinkage. default 0.2
            % * __GammaCorrection__ Flag to specify whether the gamma correction
            %       preprocessing is required or not. default true
            % * __NLevels__ Maximum number of detection window increases. default 64
            %
            % See also cv.HOGDescriptor
            %
            this.id = HOGDescriptor_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.HOGDescriptor
            %
            HOGDescriptor_(this.id, 'delete');
        end

        function s = getDescriptorSize(this)
            %GETDESCRIPTORSIZE  Returns the number of coefficients required for the classification
            %
            %    s = hog.getDescriptorSize()
            %
            % ## Output
            % * __s__ a numeric value, descriptor size
            %
            % See also cv.HOGDescriptor
            %
            s = HOGDescriptor_(this.id, 'getDescriptorSize');
        end

        function s = checkDetectorSize(this)
            %CHECKDETECTORSIZE Checks the size of the detector is valid
            %
            %    s = hog.checkDetectorSize()
            %
            % ## Output
            % * __s__ a logical value, validity of detector size
            %
            % See also cv.HOGDescriptor
            %
            s = HOGDescriptor_(this.id, 'checkDetectorSize');
        end

        function s = getWinSigma(this)
            %GETWINSIGMA Get window sigma
            %
            %    s = hog.getWinSigma()
            %
            % ## Output
            % * __s__ a numeric value, window sigma
            %
            % See also cv.HOGDescriptor
            %
            s = HOGDescriptor_(this.id, 'getWinSigma');
        end

        function setSVMDetector(this, detector)
            %SETSVMDETECTOR  Sets coefficients for the linear SVM classifier
            %
            %    hog.setSVMDetector(detector)
            %
            % ## Input
            % * __detector__ can be 'Default' or 'Daimler' for classifiers trained
            %       for people detection, or a numeric vector for other uses.
            %       * __Default__ coefficients of the classifier trained for people
            %             detection (for default window size).
            %       * __Daimler__ 1981 SVM coeffs obtained from daimler's base. To
            %             use these coeffs the detection window size should be (48,96)
            %
            % See also cv.HOGDescriptor
            %
            HOGDescriptor_(this.id, 'setSVMDetector', detector);
        end

        function status = load(this, filename)
            %LOAD  Loads a HOG descriptor config from a file
            %
            %    S = hog.load(filename)
            %
            % ## Input
            % * __filename__ HOG descriptor config filename
            %
            % ## Output
            % * __S__ a logical value indicating success of load when true
            %
            % See also cv.HOGDescriptor
            %
            status = HOGDescriptor_(this.id, 'load', filename);
        end

        function save(this, filename)
            %SAVE  Saves a HOG descriptor config to a file
            %
            %     hog.save(filename)
            %
            % ## Input
            % * __filename__ HOG descriptor config filename
            %
            % See also cv.HOGDescriptor
            %
            HOGDescriptor_(this.id, 'save', filename);
        end

        function descs = compute(this, im, varargin)
            %COMPUTE Compute HOG descriptors
            %
            %    descs = hog.compute(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __descs__ Row vectors of hog descriptors, reshaped into a
            %       matrix with `hog.getDescriptorSize()` columns
            %
            % ## Options
            % * __WinStride__ 2-element array [x,y]. defaults to `CellSize`
            % * __Padding__ 2-element array [x,y]
            % * __Locations__ cell array of 2-element arrays `{[x,y],...}` at
            %       which descriptors are computed.
            %
            % See also cv.HOGDescriptor
            %
            descs = HOGDescriptor_(this.id, 'compute', im, varargin{:});
        end

        function [pts, weights] = detect(this, im, varargin)
            %DETECT  Performs object detection without a multi-scale window
            %
            %    pts = hog.detect(im, 'Option', optionValue, ...)
            %    [pts, weights] = hog.detect(...)
            %
            % The detected objects are returned as a cell array of points,
            % with the left-top corner points of detected objects boundaries.
            % Width and height of boundaries are specified by the `WinSize`.
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __pts__ Cell array of points where objects are found.
            %       Points of the form `{[x,y], ...}`
            % * __weights__ Vector of associated weights.
            %
            % ## Options
            % * __HitThreshold__ Threshold for the distance between features
            %       and SVM classifying plane. default 0
            % * __WinStride__ Window stride. 2-element array [x,y]
            % * __Padding__ 2-element array [x,y]
            % * __Locations__ cell array of 2-element arrays `{[x,y],...}` at
            %       which detector is executed.
            %
            % See also cv.HOGDescriptor
            %
            [pts, weights] = HOGDescriptor_(this.id, 'detect', im, varargin{:});
        end

        function [rcts, weights] = detectMultiScale(this, im, varargin)
            %DETECT  Performs object detection with a multi-scale window
            %
            %    rcts = hog.detectMultiScale(im, 'Option', optionValue, ...)
            %    [rcts, weights] = hog.detectMultiScale(...)
            %
            % The detected objects are returned as a cell array of rectangles.
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __rcts__ Cell array of rectangles where objects are found.
            %       Rectangles of the form `{[x,y,width,height], ...}`
            % * __weights__ Vector of associated weights.
            %
            % ## Options
            % * __HitThreshold__ Threshold for the distance between features
            %       and SVM classifying plane. default 0
            % * __WinStride__ Window stride. 2-element array [x,y]
            % * __Padding__ 2-element array [x,y]
            % * __Scale__ Step size of scales to search. default 1.05
            % * __FinalThreshold__ Final threshold value. default 2.0
            % * __UseMeanshiftGrouping__ Flag to use meanshift grouping.
            %       default false
            %
            % See also cv.HOGDescriptor
            %
            [rcts, weights] = HOGDescriptor_(this.id, 'detectMultiScale', im, varargin{:});
        end

        function val = get.WinSize(this)
            val = HOGDescriptor_(this.id,'winSize');
        end
        function set.WinSize(this,val)
            HOGDescriptor_(this.id,'winSize',val);
        end

        function val = get.BlockSize(this)
            val = HOGDescriptor_(this.id,'blockSize');
        end
        function set.BlockSize(this,val)
            HOGDescriptor_(this.id,'blockSize',val);
        end

        function val = get.BlockStride(this)
            val = HOGDescriptor_(this.id,'blockStride');
        end
        function set.BlockStride(this,val)
            HOGDescriptor_(this.id,'blockStride',val);
        end

        function val = get.CellSize(this)
            val = HOGDescriptor_(this.id,'cellSize');
        end
        function set.CellSize(this,val)
            HOGDescriptor_(this.id,'cellSize',val);
        end

        function val = get.NBins(this)
            val = HOGDescriptor_(this.id,'nbins');
        end
        function set.NBins(this,val)
            HOGDescriptor_(this.id,'nbins',val);
        end

        function val = get.DerivAperture(this)
            val = HOGDescriptor_(this.id,'derivAperture');
        end
        function set.DerivAperture(this,val)
            HOGDescriptor_(this.id,'derivAperture',val);
        end

        function val = get.WinSigma(this)
            val = HOGDescriptor_(this.id,'winSigma');
        end
        function set.WinSigma(this,val)
            HOGDescriptor_(this.id,'winSigma',val);
        end

        function val = get.HistogramNormType(this)
            val = HOGDescriptor_(this.id,'histogramNormType');
        end
        function set.HistogramNormType(this,val)
            HOGDescriptor_(this.id,'histogramNormType',val);
        end

        function val = get.L2HysThreshold(this)
            val = HOGDescriptor_(this.id,'L2HysThreshold');
        end
        function set.L2HysThreshold(this,val)
            HOGDescriptor_(this.id,'L2HysThreshold',val);
        end

        function val = get.GammaCorrection(this)
            val = HOGDescriptor_(this.id,'gammaCorrection');
        end
        function set.GammaCorrection(this,val)
            HOGDescriptor_(this.id,'gammaCorrection',val);
        end

        function val = get.NLevels(this)
            val = HOGDescriptor_(this.id,'nlevels');
        end
        function set.NLevels(this,val)
            HOGDescriptor_(this.id,'nlevels',val);
        end

        function val = get.SvmDetector(this)
            val = HOGDescriptor_(this.id,'svmDetector');
        end
    end

    methods (Hidden)
        function [grad, angleOfs] = computeGradient(this, im, varargin)
            %COMPUTEGRADIENT  Computes gradient
            %
            %    grad = hog.computeGradient(im, 'Option', optionValue, ...)
            %    [grad, angleOfs] = hog.computeGradient(...)
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __grad__ gradient magnitudes
            %       (2 channels matrix of same size as image + padding)
            % * __angleOfs__ quantized gradient orientation
            %       with integers in the range [0,NBins-1]
            %       (2 channels matrix of same size as image + padding)
            %
            % ## Options
            % * __paddingTL__
            % * __paddingBR__
            %
            % See also cv.HOGDescriptor
            %
            [grad, angleOfs] = HOGDescriptor_(this.id, 'computeGradient', im, varargin{:});
        end

        function readALTModel(this, modelfile)
            %READALTMODEL  Read model from SVMlight format
            %
            %    hog.readALTModel(modelfile)
            %
            % ## Input
            % * __modelfile__ name of model file in SVMlight format
            %
            % See also cv.HOGDescriptor
            %
            HOGDescriptor_(this.id, 'readALTModel', modelfile);
        end
    end

end
