classdef DescriptorExtractor < handle
    %DESCRIPTOREXTRACTOR  Common interface of 2D image Descriptor Extractors.
    %
    % Class for computing descriptors for image keypoints.
    %
    % Extractors of keypoint descriptors in OpenCV have wrappers with a common
    % interface that enables you to easily switch between different algorithms
    % solving the same problem. This section is devoted to computing
    % descriptors represented as vectors in a multidimensional space. All
    % objects that implement the vector descriptor extractors inherit the
    % DescriptorExtractor interface.
    %
    % In this interface, a keypoint descriptor can be represented as a dense,
    % fixed-dimension vector of a basic type. Most descriptors follow this
    % pattern as it simplifies computing distances between descriptors.
    % Therefore, a collection of descriptors is represented as a matrix,
    % where each row is a keypoint descriptor.
    %
    % ## Example
    %
    %    detector = cv.FeatureDetector('ORB');
    %    keypoints = detector.detect(img);
    %    extractor = cv.DescriptorExtractor('ORB');
    %    descriptors = extractor.compute(img, keypoints);
    %
    % See also: cv.FeatureDetector, cv.DescriptorMatcher,
    %  cv.BOWImgDescriptorExtractor, extractFeatures
    %

    properties (SetAccess = private)
        id    % Object ID
        Type  % Type of the extractor
    end

    methods
        function this = DescriptorExtractor(extractorType, varargin)
            %DESCRIPTOREXTRACTOR  Creates a descriptor extractor by name.
            %
            %    extractor = cv.DescriptorExtractor(type)
            %    extractor = cv.DescriptorExtractor(type, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __type__ The following extractor types are supported:
            %       * __BRISK__ see cv.BRISK
            %       * __ORB__ see cv.ORB (default)
            %       * __KAZE__ see cv.KAZE
            %       * __AKAZE__ see cv.AKAZE
            %       * __SIFT__ see cv.SIFT (requires `xfeatures2d` module)
            %       * __SURF__ see cv.SURF (requires `xfeatures2d` module)
            %       * __FREAK__ see cv.FREAK (requires `xfeatures2d` module)
            %       * __BriefDescriptorExtractor__ see cv.BriefDescriptorExtractor
            %             (requires `xfeatures2d` module)
            %       * __LUCID__ see cv.LUCID (requires `xfeatures2d` module)
            %       * __LATCH__ see cv.LATCH (requires `xfeatures2d` module)
            %       * __DAISY__ see cv.DAISY (requires `xfeatures2d` module)
            %
            % ## Options
            % Refer to the constructors of each descriptor extractor for a
            % list of supported options.
            %
            % See also cv.DescriptorExtractor.compute
            %
            if nargin < 1, extractorType = 'ORB'; end
            this.Type = extractorType;
            this.id = DescriptorExtractor_(0, 'new', extractorType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.DescriptorExtractor
            %
            DescriptorExtractor_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = extractor.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = DescriptorExtractor_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    extractor.clear()
            %
            % See also: cv.DescriptorExtractor.empty,
            %  cv.DescriptorExtractor.load
            %
            DescriptorExtractor_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty.
            %
            %    b = extractor.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.DescriptorExtractor.clear,
            %  cv.DescriptorExtractor.load
            %
            b = DescriptorExtractor_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %    extractor.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.DescriptorExtractor.load
            %
            DescriptorExtractor_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %    extractor.load(fname)
            %    extractor.load(str, 'FromString',true)
            %    extractor.load(..., 'OptionName',optionValue, ...)
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
            % See also: cv.DescriptorExtractor.save
            %
            DescriptorExtractor_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %    name = extractor.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.DescriptorExtractor.save,
            %  cv.DescriptorExtractor.load
            %
            name = DescriptorExtractor_(this.id, 'getDefaultName');
        end
    end

    %% Features2D
    methods
        function ntype = defaultNorm(this)
            %DEFAULTNORM  Returns the default norm type
            %
            %    ntype = extractor.defaultNorm()
            %
            % ## Output
            % * __ntype__ Norm type. One of `cv::NormTypes`:
            %       * __Inf__
            %       * __L1__
            %       * __L2__
            %       * __L2Sqr__
            %       * __Hamming__
            %       * __Hamming2__
            %
            % See also: cv.DescriptorExtractor.compute, cv.DescriptorMatcher
            %
            ntype = DescriptorExtractor_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = extractor.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % See also: cv.DescriptorExtractor.descriptorType,
            %  cv.DescriptorExtractor.compute
            %
            sz = DescriptorExtractor_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = extractor.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % See also: cv.DescriptorExtractor.descriptorSize,
            %  cv.DescriptorExtractor.compute
            %
            dtype = DescriptorExtractor_(this.id, 'descriptorType');
        end

        function [descriptors, keypoints] = compute(this, img, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = extractor.compute(img, keypoints)
            %    [descriptors, keypoints] = extractor.compute(imgs, keypoints)
            %
            % ## Input
            % * __img__ Image (first variant).
            % * __imgs__ Image set (second variant), cell array of images.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example: cv.SIFT
            %       duplicates keypoint with several dominant orientations
            %       (for each orientation). In the first variant, this is a
            %       struct-array of detected keypoints. In the second variant,
            %       it is a cell-array, where `keypoints{i}` is a set of keypoints
            %       detected in `images{i}` (a struct-array like before).
            %       Each keypoint is a struct with the following fields:
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
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %       the method `descriptors{i}` are descriptors computed for a
            %       `keypoints{i}`. Row `j` in `descriptors` (or
            %       `descriptors{i}`) is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also cv.DescriptorExtractor.DescriptorExtractor
            %
            [descriptors, keypoints] = DescriptorExtractor_(this.id, 'compute', img, keypoints);
        end
    end

end
