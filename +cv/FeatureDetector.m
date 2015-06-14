classdef FeatureDetector < handle
    %FEATUREDETECTOR  Common interface of 2D image Feature Detectors.
    %
    % Class for detecting keypoints in images.
    %
    % Feature detectors in OpenCV have wrappers with a common interface that
    % enables you to easily switch between different algorithms solving the
    % same problem. All objects that implement keypoint detectors inherit the
    % FeatureDetector interface.
    %
    % ## Example
    %
    %    detector = cv.FeatureDetector('SURF');
    %    keypoints = detector.detect(img);
    %
    % See also: cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
        Type  % Type of the detector
    end

    methods
        function this = FeatureDetector(detectorType, varargin)
            %FEATUREDETECTOR  Creates a feature detector by name.
            %
            %    detector = cv.FeatureDetector(type)
            %    detector = cv.FeatureDetector(type, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __type__ The following detector types are supported:
            %       * 'BRISK' cv.BRISK
            %       * 'ORB' cv.ORB
            %       * 'MSER' cv.MSER
            %       * 'FastFeatureDetector' cv.FastFeatureDetector (default)
            %       * 'GFTTDetector' cv.GFTTDetector
            %       * 'SimpleBlobDetector' cv.SimpleBlobDetector
            %       * 'KAZE' cv.KAZE
            %       * 'AKAZE' cv.AKAZE
            %       * 'AgastFeatureDetector' cv.AgastFeatureDetector
            %       * 'SIFT' cv.SIFT (requires `xfeatures2d` module)
            %       * 'SURF' cv.SURF (requires `xfeatures2d` module)
            %       * 'StarDetector' cv.StarDetector (requires `xfeatures2d` module)
            %
            % ## Options
            % Refer to the constructors of each feature detector for a
            % list of supported options.
            %
            % See also cv.FeatureDetector.detect
            %
            if nargin < 1, detectorType = 'FastFeatureDetector'; end
            this.Type = detectorType;
            this.id = FeatureDetector_(0, 'new', detectorType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = FeatureDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.FeatureDetector.empty
            %
            FeatureDetector_(this.id, 'clear');
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
            % See also: cv.FeatureDetector.save, cv.FeatureDetector.load
            %
            name = FeatureDetector_(this.id, 'getDefaultName');
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
            % See also: cv.FeatureDetector.load
            %
            FeatureDetector_(this.id, 'save', filename);
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
            % See also: cv.FeatureDetector.save
            %
            FeatureDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.FeatureDetector.clear
            %
            b = FeatureDetector_(this.id, 'empty');
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
            n = FeatureDetector_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = FeatureDetector_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = FeatureDetector_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, image, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(image)
            %    keypoints = obj.detect(images)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Inputs
            % * __image__ Image.
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
            %       In the second variant of the method `keypoints{i}` is a
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
            % See also: cv.FeatureDetector
            %
            keypoints = FeatureDetector_(this.id, 'detect', image, varargin{:});
        end
    end

end
