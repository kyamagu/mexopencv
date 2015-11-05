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
    %    detector = cv.FeatureDetector('ORB');
    %    keypoints = detector.detect(img);
    %
    % See also: cv.DescriptorExtractor, cv.KeyPointsFilter, cv.drawKeypoints
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
            %       * __BRISK__ see cv.BRISK
            %       * __ORB__ see cv.ORB
            %       * __MSER__ see cv.MSER
            %       * __FastFeatureDetector__ see cv.FastFeatureDetector
            %             (default)
            %       * __GFTTDetector__ see cv.GFTTDetector
            %       * __SimpleBlobDetector__ see cv.SimpleBlobDetector
            %       * __KAZE__ see cv.KAZE
            %       * __AKAZE__ see cv.AKAZE
            %       * __AgastFeatureDetector__ see cv.AgastFeatureDetector
            %       * __SIFT__ see cv.SIFT (requires `xfeatures2d` module)
            %       * __SURF__ see cv.SURF (requires `xfeatures2d` module)
            %       * __StarDetector__ see cv.StarDetector (requires
            %             `xfeatures2d` module)
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
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = FeatureDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.FeatureDetector.empty, cv.FeatureDetector.load
            %
            FeatureDetector_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty.
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.FeatureDetector.clear, cv.FeatureDetector.load
            %
            b = FeatureDetector_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.FeatureDetector.load
            %
            FeatureDetector_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
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
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.FeatureDetector.save
            %
            FeatureDetector_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
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
    end

    %% Features2D
    methods
        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(img)
            %    keypoints = obj.detect(imgs)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant).
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. In the first variant,
            %       a 1-by-N structure array. In the second variant of the
            %       method, `keypoints{i}` is a set of keypoints detected in
            %       `imgs{i}`. Each keypoint is a struct with the following
            %       fields:
            %       * __pt__ coordinates of the keypoint `[x,y]`
            %       * __size__ diameter of the meaningful keypoint neighborhood
            %       * __angle__ computed orientation of the keypoint (-1 if not
            %             applicable); it's in [0,360) degrees and measured
            %             relative to image coordinate system (y-axis is
            %             directed downward), i.e in clockwise.
            %       * __response__ the response by which the most strong
            %             keypoints have been selected. Can be used for further
            %             sorting or subsampling.
            %       * __octave__ octave (pyramid layer) from which the keypoint
            %             has been extracted.
            %       * **class_id** object class (if the keypoints need to be
            %             clustered by an object they belong to).
            %
            % ## Options
            % * __Mask__ A mask specifying where to look for keypoints
            %       (optional). It must be a logical or 8-bit integer matrix
            %       with non-zero values in the region of interest. In the
            %       second variant, it is a cell-array of masks for each input
            %       image, `masks{i}` is a mask for `imgs{i}`.
            %       Not set by default.
            %
            % See also: cv.FeatureDetector.FeatureDetector
            %
            keypoints = FeatureDetector_(this.id, 'detect', img, varargin{:});
        end
    end

end
