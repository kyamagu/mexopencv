classdef FastFeatureDetector < handle
    %FASTFEATUREDETECTOR  Wrapping class for feature detection using the FAST method.
    %
    % Detects corners using the FAST algorithm by [Rosten06].
    %
    % ## References:
    % [Rosten06]:
    % > Edward Rosten and Tom Drummond.
    % > "Machine Learning for High-speed Corner Detection".
    % > In Computer Vision-ECCV 2006, pages 430-443. Springer, 2006.
    %
    % See also: cv.AgastFeatureDetector, cv.FeatureDetector
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Threshold on difference between intensity of the central pixel
        % and pixels of a circle around this pixel.
        Threshold
        % If true, non-maximum suppression is applied to detected corners
        % (keypoints).
        NonmaxSuppression
        % One of the three neighborhoods as defined in the paper:
        %
        % * __TYPE_5_8__
        % * __TYPE_7_12__
        % * __TYPE_9_16__
        Type
    end

    methods
        function this = FastFeatureDetector(varargin)
            %FASTFEATUREDETECTOR  Constructor
            %
            %    obj = cv.FastFeatureDetector()
            %    obj = cv.FastFeatureDetector(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Threshold__  default 10
            % * __NonmaxSuppression__ default true
            % * __Type__ default 'TYPE_9_16'
            %
            % See also: cv.FastFeatureDetector.detect
            %
            this.id = FastFeatureDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.FastFeatureDetector
            %
            FastFeatureDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = FastFeatureDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.FastFeatureDetector.empty
            %
            FastFeatureDetector_(this.id, 'clear');
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
            % See also: cv.FastFeatureDetector.save, cv.FastFeatureDetector.load
            %
            name = FastFeatureDetector_(this.id, 'getDefaultName');
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
            % See also: cv.FastFeatureDetector.load
            %
            FastFeatureDetector_(this.id, 'save', filename);
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
            % See also: cv.FastFeatureDetector.save
            %
            FastFeatureDetector_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Features2D
    methods
        function b = empty(this)
            %EMPTY  Checks if detector object is empty.
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty
            %       (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.FastFeatureDetector.clear
            %
            b = FastFeatureDetector_(this.id, 'empty');
        end

        function n = defaultNorm(this)
            %DEFAULTNORM  Returns the default norm type
            %
            %    norm = obj.defaultNorm()
            %
            % ## Output
            % * __norm__ Norm type. One of `cv::NormTypes`:
            %       * __Inf__
            %       * __L1__
            %       * __L2__
            %       * __L2Sqr__
            %       * __Hamming__
            %       * __Hamming2__
            %
            n = FastFeatureDetector_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = FastFeatureDetector_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = FastFeatureDetector_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, image, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(image)
            %    keypoints = obj.detect(images)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Inputs
            % * __image__ Image, grayscale image where keypoints (corners)
            %       are detected.
            % * __images__ Image set.
            %
            % ## Outputs
            % * __keypoints__ The detected keypoints.
            %       A 1-by-N structure array with the following fields:
            %       * __pt__ coordinates of the keypoint `[x,y]`
            %       * __size__ diameter of the meaningful keypoint neighborhood
            %       * __angle__ computed orientation of the keypoint (-1 if not
            %             applicable). Its possible values are in a range
            %             [0,360) degrees. It is measured relative to image
            %             coordinate system (y-axis is directed downward), i.e
            %             in clockwise.
            %       * __response__ the response by which the most strong
            %             keypoints have been selected. Can be used for further
            %             sorting or subsampling.
            %       * __octave__ octave (pyramid layer) from which the keypoint
            %             has been extracted.
            %       * **class_id** object id that can be used to clustered
            %             keypoints by an object they belong to.
            %
            %       In the second variant of the method `keypoints(i)` is a
            %       set of keypoints detected in `images{i}`.
            %
            % ## Options
            % * __Mask__ In the first variant, a mask specifying where to look
            %       for keypoints (optional). It must be a logical or 8-bit
            %       integer matrix with non-zero values in the region of
            %       interest.
            %       In the second variant, a cell-array of masks for each input
            %       image specifying where to look for keypoints (optional).
            %       `masks{i}` is a mask for `images{i}`.
            %       default none
            %
            % See also: cv.FastFeatureDetector.FastFeatureDetector
            %
            keypoints = FastFeatureDetector_(this.id, 'detect', image, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Threshold(this)
            value = FastFeatureDetector_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            FastFeatureDetector_(this.id, 'set', 'Threshold', value);
        end

        function value = get.NonmaxSuppression(this)
            value = FastFeatureDetector_(this.id, 'get', 'NonmaxSuppression');
        end
        function set.NonmaxSuppression(this, value)
            FastFeatureDetector_(this.id, 'set', 'NonmaxSuppression', value);
        end

        function value = get.Type(this)
            value = FastFeatureDetector_(this.id, 'get', 'Type');
        end
        function set.Type(this, value)
            FastFeatureDetector_(this.id, 'set', 'Type', value);
        end
    end

end
