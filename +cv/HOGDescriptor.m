classdef HOGDescriptor < handle
    %HOGDESCRIPTOR  Histogram of Oriented Gaussian (HOG) descriptor and detector
    %
    % The class implements Histogram of Oriented Gradients object detector
    % [Dalal2005].
    %
    % ## Example
    % The basic usage is the following for computing HOG descriptors:
    %
    %    hog = cv.HOGDescriptor();
    %    descriptors = hog.compute(im);
    %
    % This computes descriptors in a "dense" setting; Each row is a feature
    % vector computed from a window of size `WinSize` slided across the input
    % image gradient. Each vector element is a histogram of gradient
    % orientations (quantized into `NBins` directions). The histogram is
    % collected within a "cell" of pixels of size `CellSize`, and locally
    % normalized (see `HistogramNormType` and `L2HysThreshold`) over larger
    % spatial "block" regions of size `BlockSize` overlapped according to
    % `BlockStride`. See cv.HOGDescriptor.getDescriptorSize.
    %
    % If you need to compute descriptors for a set of certain "sparse"
    % keypoints (for example SIFT or SURF keypoints), use the `Locations`
    % option of the compute method:
    %
    %    keypoints = cv.FAST(im);
    %    descriptors = hog.compute(im, 'Locations', {keypoints.pt});
    %
    % The next step in object recognition using HOG descriptors is to feed the
    % descriptors computed from positive and negative images into a linear SVM
    % classifier trained to classify whether a window is an object or not.
    % This trained SVM model is represented by a set of coefficients for each
    % element in the feature vector. This vector is assigned to the
    % cv.HOGDescriptor.SvmDetector property.
    %
    % Alternatively, you can use the default built-in people detector which is
    % accessible by name as:
    %
    %    % detect and localize upright people in images
    %    hog.SVMDetector = 'DefaultPeopleDetector';
    %    boxes = hog.detectMultiScale(im);
    %
    % In this case, there is no need to train an SVM model.
    %
    % Either way, you simply call the detect methods which use the saved
    % coefficients on the input feature-vector to compute a weighted sum. If
    % the sum is greater than a user-specified threshold `HitThreshold`, then
    % it is classified an object (a pedestrian in the case of the builtin
    % detectors).
    %
    % The cv.HOGDescriptor.detectMultiScale method detects at multiple scales
    % (see `NLevels` and `Scale`) and directly returns the bounding boxes. The
    % cv.HOGDescriptor.detect method returns a list of top-left corner points,
    % where the detected object size is the same as the detector's window
    % size.
    %
    % ## References
    % [Dalal2005]:
    % > Navneet Dalal and Bill Triggs. "Histogram of oriented gradients for
    % > human detection". CVPR 2005.
    % > http://lear.inrialpes.fr/pubs/2005/DT05/
    %
    % See also: cv.HOGDescriptor.HOGDescriptor, cv.HOGDescriptor.compute,
    %  cv.HOGDescriptor.detect, cv.HOGDescriptor.detectMultiScale,
    %  extractHOGFeatures
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
        SignedGradient    % Signed gradient
        % Coefficients for the linear SVM classifier.
        %
        % You can either specify a pretrained classier for people detection
        % by name, or directly set a numeric vector of SVM coefficients for
        % other uses. The avaiable pretrained classifiers are:
        %
        % * __DefaultPeopleDetector__ coefficients of the classifier trained
        %       for people detection (for default window size).
        % * __DaimlerPeopleDetector__ 1981 SVM coeffs obtained from daimler's
        %       base. To use these coeffs the detection window size should be
        %       [48,96].
        %
        % See also: cv.HOGDescriptor.checkDetectorSize,
        % cv.HOGDescriptor.load, cv.HOGDescriptor.readALTModel
        %
        SvmDetector
    end

    methods
        function this = HOGDescriptor(varargin)
            %HOGDESCRIPTOR  Create a new or load an existing HOG descriptor and detector
            %
            %    hog = cv.HOGDescriptor()
            %    hog = cv.HOGDescriptor('PropertyName', propertyValue, ...)
            %    hog = cv.HOGDescriptor(filename)
            %
            % ## Input
            % * __filename__ Filename of existing HOG descriptor config to
            %       load from (XML or YAML). This is handled by the load
            %       method.
            %
            % ## Output
            % * __hog_ HOG descriptor object.
            %
            % ## Options
            % * __WinSize__ Detection window size. Align to block size and
            %       block stride. default [64,128]
            % * __BlockSize__ Block size in pixels. Align to cell size.
            %       default [16,16]
            % * __BlockStride__ Block stride. It must be a multiple of cell
            %       size. default [8,8]
            % * __CellSize__ Cell size. default [8,8]
            % * __NBins__ Number of bins. default 9
            % * __DerivAperture__ Derivative of aperture. default 1
            % * __WinSigma__ Gaussian smoothing window parameter. default -1
            %       (corresponds to `sum(BlockSize)/8`)
            % * __HistogramNormType__ Histogram normalization method.
            %       default 'L2Hys'
            % * __L2HysThreshold__ L2-Hys normalization method shrinkage.
            %       default 0.2
            % * __GammaCorrection__ Flag to specify whether the gamma
            %       correction preprocessing is required or not. default true
            % * __NLevels__ Maximum number of detection window increases.
            %       default 64
            % * __SignedGradient__ Flag to specify whether orientations range
            %       in 0-180 (false) or 0-360 (true) degrees. 0-180 mean that
            %       positive/negative directions count as the same histogram
            %       bin. default false
            %
            % See also: cv.HOGDescriptor.load
            %
            if nargin == 1 && ischar(varargin{1})
                this.id = HOGDescriptor_(0, 'new');
                this.load(varargin{1});
            else
                this.id = HOGDescriptor_(0, 'new', varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.HOGDescriptor
            %
            HOGDescriptor_(this.id, 'delete');
        end

        function status = load(this, filename, varargin)
            %LOAD  Loads a HOG descriptor config from a file
            %
            %    status = hog.load(filename)
            %    status = obj.load(filename, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ HOG descriptor config filename (XML or YAML).
            %
            % ## Output
            % * __status__ a logical value indicating success of load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            %
            % See also: cv.HOGDescriptor.save, cv.HOGDescriptor.readALTModel
            %
            status = HOGDescriptor_(this.id, 'load', filename, varargin{:});
        end

        function save(this, filename, varargin)
            %SAVE  Saves a HOG descriptor config to a file
            %
            %     hog.save(filename)
            %     hog.save(filename, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ HOG descriptor config filename (XML or YAML).
            %
            % ## Options
            % * __ObjName__ The optional name of the node to write (if empty,
            %       a default name value will be used). default empty
            %
            % See also: cv.HOGDescriptor.load
            %
            HOGDescriptor_(this.id, 'save', filename, varargin{:});
        end

        function readALTModel(this, modelfile)
            %READALTMODEL  Read model from SVMlight format
            %
            %    hog.readALTModel(modelfile)
            %
            % ## Input
            % * __modelfile__ name of trained model file in SVMlight format.
            %
            % Read/parse Dalal's alt model file.
            %
            % See also: cv.HOGDescriptor.SvmDetector, cv.HOGDescriptor.load
            %
            HOGDescriptor_(this.id, 'readALTModel', modelfile);
        end

        function sz = getDescriptorSize(this)
            %GETDESCRIPTORSIZE  Returns the number of coefficients required for the classification
            %
            %    sz = hog.getDescriptorSize()
            %
            % ## Output
            % * __sz__ a numeric value, descriptor size.
            %
            % The desriptor size is computed in the following way:
            %
            %    cells_per_block = hog.BlockSize ./ hog.CellSize
            %    histsize_per_block = prod(cells_per_block) * hog.NBins
            %    blocks_per_window = (hog.WinSize - hog.BlockSize) ./ hog.BlockStride + 1
            %    descriptor_size = prod(blocks_per_window) * histsize_per_block
            %
            % See also: cv.HOGDescriptor.compute
            %
            sz = HOGDescriptor_(this.id, 'getDescriptorSize');
        end

        function tf = checkDetectorSize(this)
            %CHECKDETECTORSIZE  Checks the size of the detector is valid
            %
            %    tf = hog.checkDetectorSize()
            %
            % ## Output
            % * __tf__ a logical value, indicates validity of detector size.
            %
            % The detector is considered valid if the coefficients vector is
            % either empty or has length matching `hog.getDescriptorSize()` or
            % `hog.getDescriptorSize()+1`.
            %
            % See also: cv.HOGDescriptor.SvmDetector
            %
            tf = HOGDescriptor_(this.id, 'checkDetectorSize');
        end

        function ws = getWinSigma(this)
            %GETWINSIGMA  Get window sigma
            %
            %    ws = hog.getWinSigma()
            %
            % ## Output
            % * __ws__ a numeric value, window sigma.
            %
            % This returns `hog.WinSigma` or `sum(hog.BlockSize)/8` if it is
            % negative.
            %
            % See also: cv.HOGDescriptor.WinSigma, cv.HOGDescriptor.BlockSize
            %
            ws = HOGDescriptor_(this.id, 'getWinSigma');
        end

        function descs = compute(this, im, varargin)
            %COMPUTE  Returns HOG block descriptors computed for the whole image
            %
            %    descs = hog.compute(im)
            %    descs = hog.compute(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ 8-bit 1- or 3-channel source image.
            %
            % ## Output
            % * __descs__ Row vectors of HOG descriptors, with the number of
            %       columns equal to `hog.getDescriptorSize()`.
            %
            % ## Options
            % * __WinStride__ Window stride `[w,h]`. It must be a multiple of
            %       block stride. Not set by default in which case it uses
            %       `CellSize`.
            % * __Padding__ Optional padding `[w,h]`. default [0,0]
            % * __Locations__ cell array of 2D points `{[x,y],...}` at which
            %       descriptors are computed. Not set by default (in which
            %       case descriptors are computed for the whole image with a
            %       sliding window).
            %
            % In case of "dense" descriptors (i.e `Locations` is not set), the
            % number of rows is equal to the number of sliding windows over
            % the image. Assuming zero padding, this is computed in the
            % following way:
            %
            %    [h,w,~] = size(im);
            %    % numel(hog.WinSize(1):hog.CellSize(1):w)
            %    % numel(hog.WinSize(2):hog.CellSize(2):h)
            %    windows_per_img = ([w,h] - hog.WinSize) ./ WinStride + 1
            %    num_windows = prod(windows_per_img)
            %
            % The windows cover the image in a top-to-bottom left-to-right
            % order.
            %
            % In case of "sparse" descriptors (i.e `Locations` is set), the
            % number of rows is equal to the number of locations specified.
            %
            % The function is mainly used to learn the classifier.
            %
            % The computed feature vectors are compatible with the
            % INRIA Object Detection and Localization Toolkit
            % (http://pascal.inrialpes.fr/soft/olt/).
            %
            % See also cv.HOGDescriptor.computeGradient
            %
            descs = HOGDescriptor_(this.id, 'compute', im, varargin{:});
        end

        function [grad, angleOfs] = computeGradient(this, im, varargin)
            %COMPUTEGRADIENT  Computes gradient
            %
            %    [grad, angleOfs] = hog.computeGradient(im)
            %    [...] = hog.computeGradient(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ 8-bit 1- or 3-channel source image.
            %
            % ## Output
            % * __grad__ gradient magnitudes (2-channel float matrix of same
            %       size as the image plus padding).
            % * __angleOfs__ quantized gradient orientation with integers in
            %       the range `[0,NBins-1]` (2-channel 8-bit matrix of same
            %       size as the image plus the padding).
            %
            % ## Options
            % * __paddingTL__ Optional padding. default [0,0]
            % * __paddingBR__ Optional padding. default [0,0]
            %
            % See also: cv.HOGDescriptor.compute
            %
            [grad, angleOfs] = HOGDescriptor_(this.id, 'computeGradient', im, varargin{:});
        end

        function [pts, weights] = detect(this, im, varargin)
            %DETECT  Performs object detection without a multi-scale window
            %
            %    [pts, weights] = hog.detect(im)
            %    [...] = hog.detect(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ 8-bit 1- or 3-channel image where objects are detected.
            %
            % ## Output
            % * __pts__ Left-top corner points of detected objects boundaries.
            %       A cell array of points where objects are found of the form
            %       `{[x,y], ...}`. The width and height of boundaries are
            %       specified by the `WinSize` parameter.
            % * __weights__ Ouput vector of associated weights.
            %
            % ## Options
            % * __HitThreshold__ Threshold for the distance between features
            %       and SVM classifying plane. Usually it is 0 and should be
            %       specfied in the detector coefficients (as the last free
            %       coefficient). But if the free coefficient is omitted
            %       (which is allowed), you can specify it manually here.
            %       default 0
            % * __WinStride__ Window stride `[w,h]`. It must be a multiple of
            %       block stride. Not set by default in which case it uses
            %       `CellSize`.
            % * __Padding__ Padding `[w,h]`. default [0,0]
            % * __Locations__ cell array of 2-element points `{[x,y],...}` at
            %       which detector is executed. Not set by default, in which
            %       case the whole image is searched with a sliding window.
            %
            % `SvmDetector` should be set before calling this method.
            %
            % See also: cv.HOGDescriptor.detectMultiScale
            %
            [pts, weights] = HOGDescriptor_(this.id, 'detect', im, varargin{:});
        end

        function [rcts, weights] = detectMultiScale(this, im, varargin)
            %DETECTMULTISCALE  Performs object detection with a multi-scale window
            %
            %    [rcts, weights] = hog.detectMultiScale(im)
            %    [...] = hog.detectMultiScale(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ 8-bit 1- or 3-channel image where objects are detected.
            %
            % ## Output
            % * __rcts__ Detected objects boundaries. Cell array of rectangles
            %       where objects are found, of the form `{[x,y,w,h], ...}`.
            % * __weights__ Vector of associated weights.
            %
            % ## Options
            % * __HitThreshold__ Threshold for the distance between features
            %       and SVM classifying plane. Usually it is 0 and should be
            %       specfied in the detector coefficients (as the last free
            %       coefficient). But if the free coefficient is omitted
            %       (which is allowed), you can specify it manually here.
            %       default 0
            % * __WinStride__ Window stride `[w,h]`. It must be a multiple of
            %       block stride. Not set by default in which case it uses
            %       `BlockStride`.
            % * __Padding__ Padding `[w,h]`. default [0,0]
            % * __Scale__ Coefficient of the detection window increase.
            %       default 1.05
            % * __FinalThreshold__ Coefficient to regulate the similarity
            %       threshold. When detected, some objects can be covered by
            %       many rectangles. 0 means not to perform grouping. See
            %       cv.groupRectangles. default 2.0
            % * __UseMeanshiftGrouping__ Flag to use meanshift grouping or the
            %       default grouping based on merging overlapped rectangles.
            %       When false, cv.HOGDes.groupRectangles is performed and the
            %       value of `FinalThreshold` is used for `GroupThreshold`.
            %       When true, cv.groupRectangles_meanshift is performed
            %       instead, and `FinalThreshold` is used for the
            %       `DetectThreshold` option. default false
            %
            % `SvmDetector` should be set before calling this method.
            %
            % The image is repeatedly scaled down by the specified `Scale`
            % factor, as long as it remains larger than `hog.WinSize` or until
            % a maximum of `hog.NLevels` levels is built. The resized images
            % are then searched with a sliding window to detect objects
            % similar to the cv.HOGDescriptor.detect method (this method is
            % parallelized). Finally the found rectangles are grouped and
            % clipped against the image size.
            %
            % See also: cv.HOGDescriptor.detect
            %
            [rcts, weights] = HOGDescriptor_(this.id, 'detectMultiScale', im, varargin{:});
        end

        function [pts, confidences] = detectROI(this, im, locations, varargin)
            %DETECTROI  Evaluate specified ROI and return confidence value for each location
            %
            %    [pts, confidences] = hog.detectROI(im, locations)
            %    [...] = hog.detectROI(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __im__ 8-bit 1- or 3-channel image where objects are detected.
            % * __locations__ cell array of 2-element points `{[x,y],...}` at
            %       which detector is executed. These are top-left corner
            %       of candidate points at which to detect objects.
            %
            % ## Output
            % * __pts__ Left-top corner points of detected objects boundaries.
            %       A cell array of points where objects are found of the form
            %       `{[x,y], ...}`. The width and height of boundaries are
            %       specified by the `WinSize` parameter. These are the
            %       filtered `locations` at which objects where actually
            %       detected.
            % * __confidences__ vector of confidences for each of the
            %       candidate locations (prediction of the SVM classifier).
            %
            % ## Options
            % * __HitThreshold__ Threshold for the distance between features
            %       and SVM classifying plane. Usually it is 0 and should be
            %       specfied in the detector coefficients (as the last free
            %       coefficient). But if the free coefficient is omitted
            %       (which is allowed), you can specify it manually here.
            %       default 0
            % * __WinStride__ Window stride `[w,h]`. It must be a multiple of
            %       block stride. Not set by default in which case it uses
            %       `CellSize`.
            % * __Padding__ Padding `[w,h]`. default [0,0]
            %
            % See also: cv.HOGDescriptor.detect
            %
            [pts, confidences] = HOGDescriptor_(this.id, 'detectROI', im, locations, varargin{:});
        end

        function [rcts, locations] = detectMultiScaleROI(this, im, locations, varargin)
            %DETECTMULTISCALEROI  Evaluate specified ROI and return confidence value for each location in multiple scales
            %
            %    [rcts, locations] = hog.detectMultiScaleROI(im, locations)
            %    [...] = hog.detectMultiScaleROI(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __im__ 8-bit 1- or 3-channel image where objects are detected.
            % * __locations__ input detection region of interest. It specifies
            %       candidate locations to search for object detections at
            %       different scales. An struct array with the following
            %       fields:
            %       * __scale__ scale (size) of the bounding box, scalar.
            %       * __locations__ set of requrested locations to be
            %             evaluated, cell array of points `{[x,y], ...}`.
            %       * __confidences__ vector that will contain confidence
            %             values for each location. Not required on input,
            %             this will be filled/updated on output.
            %
            % ## Output
            % * __rcts__ Detected objects boundaries. Cell array of rectangles
            %       where objects are found, of the form `{[x,y,w,h], ...}`.
            % * __locations__ output updated `locations` struct array. All
            %       points are retained, but their confidences are updated.
            %
            % ## Options
            % * __HitThreshold__ Threshold for the distance between features
            %       and SVM classifying plane. Usually it is 0 and should be
            %       specfied in the detector coefficients (as the last free
            %       coefficient). But if the free coefficient is omitted
            %       (which is allowed), you can specify it manually here.
            %       default 0
            % * __GroupThreshold__ Minimum possible number of rectangles in a
            %       group minus 1. The threshold is used on a group of
            %       rectangles to decide whether to retain it or not. If less
            %       than or equal to zero, no grouping is performed. See
            %       cv.groupRectangles. default 0
            %
            % See also: cv.HOGDescriptor.detectMultiScale
            %
            [rcts, locations] = HOGDescriptor_(this.id, 'detectMultiScaleROI', im, locations, varargin{:});
        end

        function [rects, weights] = groupRectangles(this, rects, weights, varargin)
            %GROUPRECTANGLES  Groups the object candidate rectangles
            %
            %    [rects, weights] = hog.groupRectangles(rects, weights)
            %    [...] = hog.groupRectangles(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __rects__ Input cell array of rectangles, where each rectangle
            %       is represented as a 4-element vector `{[x,y,w,h], ...}`,
            %       or a numeric Nx4/Nx1x4/1xNx4 array.
            % * __weights__ Input vector of associated weights.
            %
            % ## Output
            % * __rects__ outupt updated rectangles. Grouped rectangles are
            %       the average of all rectangles in that cluster.
            % * __weights__ output updated weights. Corresponding grouped
            %       weights are the maximum weights of all rectangles in that
            %       cluster.
            %
            % ## Options
            % * __EPS__ Relative difference between sides of the rectangles to
            %       merge them into a group. default 0.2
            % * __GroupThreshold__ Minimum possible number of rectangles in a
            %       group minus 1. The threshold is used on a group of
            %       rectangles to decide whether to retain it or not. If less
            %       than or equal to zero, no grouping is performed. default 1
            %       (i.e only groups with two or more rectangles are kept).
            %
            % See also: cv.groupRectangles, cv.SimilarRects
            %
            [rects, weights] = HOGDescriptor_(this.id, 'groupRectangles', rects, weights, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function val = get.WinSize(this)
            val = HOGDescriptor_(this.id, 'get', 'WinSize');
        end
        function set.WinSize(this, value)
            HOGDescriptor_(this.id, 'set', 'WinSize', value);
        end

        function val = get.BlockSize(this)
            val = HOGDescriptor_(this.id, 'get', 'BlockSize');
        end
        function set.BlockSize(this, value)
            HOGDescriptor_(this.id, 'set', 'BlockSize', value);
        end

        function val = get.BlockStride(this)
            val = HOGDescriptor_(this.id, 'get', 'BlockStride');
        end
        function set.BlockStride(this, value)
            HOGDescriptor_(this.id, 'set', 'BlockStride', value);
        end

        function val = get.CellSize(this)
            val = HOGDescriptor_(this.id, 'get', 'CellSize');
        end
        function set.CellSize(this, value)
            HOGDescriptor_(this.id, 'set', 'CellSize', value);
        end

        function val = get.NBins(this)
            val = HOGDescriptor_(this.id, 'get', 'NBins');
        end
        function set.NBins(this, value)
            HOGDescriptor_(this.id, 'set', 'NBins', value);
        end

        function val = get.DerivAperture(this)
            val = HOGDescriptor_(this.id, 'get', 'DerivAperture');
        end
        function set.DerivAperture(this, value)
            HOGDescriptor_(this.id, 'set', 'DerivAperture', value);
        end

        function val = get.WinSigma(this)
            val = HOGDescriptor_(this.id, 'get', 'WinSigma');
        end
        function set.WinSigma(this, value)
            HOGDescriptor_(this.id, 'set', 'WinSigma', value);
        end

        function val = get.HistogramNormType(this)
            val = HOGDescriptor_(this.id, 'get', 'HistogramNormType');
        end
        function set.HistogramNormType(this, value)
            HOGDescriptor_(this.id, 'set', 'HistogramNormType', value);
        end

        function val = get.L2HysThreshold(this)
            val = HOGDescriptor_(this.id, 'get', 'L2HysThreshold');
        end
        function set.L2HysThreshold(this, value)
            HOGDescriptor_(this.id, 'set', 'L2HysThreshold', value);
        end

        function val = get.GammaCorrection(this)
            val = HOGDescriptor_(this.id, 'get', 'GammaCorrection');
        end
        function set.GammaCorrection(this, value)
            HOGDescriptor_(this.id, 'set', 'GammaCorrection', value);
        end

        function val = get.NLevels(this)
            val = HOGDescriptor_(this.id, 'get', 'NLevels');
        end
        function set.NLevels(this, value)
            HOGDescriptor_(this.id, 'set', 'NLevels', value);
        end

        function val = get.SignedGradient(this)
            val = HOGDescriptor_(this.id, 'get', 'SignedGradient');
        end
        function set.SignedGradient(this, value)
            HOGDescriptor_(this.id, 'set', 'SignedGradient', value);
        end

        function val = get.SvmDetector(this)
            val = HOGDescriptor_(this.id, 'get', 'SvmDetector');
        end
        function set.SvmDetector(this, value)
            HOGDescriptor_(this.id, 'set', 'SvmDetector', value);
        end
    end

end
