classdef HOGDescriptor < handle
    %HOGDESCRIPTOR Histogram of Oriented Gaussian descriptor
    %
    % The descriptor of [Dalal2005].
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
    
    methods
        function this = HOGDescriptor(varargin)
            %HOGDESCRIPTOR Create or load a new HOG descriptor
            %
            %    hog = cv.HOGDescriptor()
            %    hog = cv.HOGDescriptor(filename)
            %    hog = cv.HOGDescriptor('PropertyName', propertyValue, ...)
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
            %GETDESCRIPTORSIZE Get length of the descriptor
            %
            %    s = hog.getDescriptorSize()
            %
            % s is a numeric value
            %
            % See also cv.HOGDescriptor
            %
            s = HOGDescriptor_(this.id, 'getDescriptorSize');
        end
        
        function s = checkDetectorSize(this)
            %CHECKDETECTORSIZE Get size of the detector
            %
            %    s = hog.checkDetectorSize()
            %
            % s is a numeric value
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
            % s is a numeric value
            %
            % See also cv.HOGDescriptor
            %
            s = HOGDescriptor_(this.id, 'getWinSigma');
        end
        
        function setSVMDetector(this, detector)
            %SETSVMDETECTOR Set an SVM detector
            %
            %    hog.setSVMDetector(detector)
            %
            % detector can be 'Default' or 'Daimler' for people detectors,
            % or a numeric vector for other uses.
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
            % S is a logical value indicating success of load when true
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
            % * __descs__ Row vectors of hog descriptors.
            %
            % ## Options
            % * __WinStride__ 2-element array [x,y]
            % * __Padding__ 2-element array [x,y]
            % * __Locations__ cell array of 2-element arrays {[x,y],...} at
            %     which descriptors are computed.
            %
            % See also cv.HOGDescriptor
            %
            descs = HOGDescriptor_(this.id, 'compute', im, varargin{:});
        end
        
        function [pts, weights] = detect(this, im, varargin)
            %DETECT Detects objects using HOG descriptors
            %
            %    pts = hog.detect(im, 'Option', optionValue, ...)
            %    [pts, weights] = hog.detect(...)
            %
            % The detected objects are returned as a cell array of rectangles.
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __pts__ Cell array of points where objects are found.
            % * __weights__ Associated weights.
            %
            % ## Options
            % * __HitThreshold__ Parameter to specify the threshold.
            %     default 0
            % * __WinStride__ 2-element array [x,y]
            % * __Padding__ 2-element array [x,y]
            % * __Locations__ cell array of 2-element arrays {[x,y],...} at
            %     which detector is executed.
            %
            % See also cv.HOGDescriptor
            %
            [pts, weights] = HOGDescriptor_(this.id, 'detect', im, varargin{:});
        end
        
        function [rcts, weights] = detectMultiScale(this, im, varargin)
            %DETECT Detects objects using HOG descriptors
            %
            %    rcts = hog.detect(im, 'Option', optionValue, ...)
            %    [rcts, weights] = hog.detect(...)
            %
            % The detected objects are returned as a cell array of rectangles.
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __rcts__ Cell array of rectangles where objects are found.
            % * __weights__ Associated weights.
            %
            % ## Options
            % * __HitThreshold__ Parameter to specify the threshold.
            %     default 0
            % * __WinStride__ 2-element array [x,y]
            % * __Padding__ 2-element array [x,y]
            % * __Scale__ Step size of scales to search. default 1.05
            % * __FinalThreshold__ Final threshold value. default 2.0
            % * __UseMeanshiftGrouping__ Flag to use meanshift grouping.
            %     default false
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
    end
    
end

