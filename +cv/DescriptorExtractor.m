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
    %    detector = cv.FeatureDetector('SURF');
    %    keypoints = detector.detect(img);
    %    extractor = cv.DescriptorExtractor('SURF');
    %    descriptors = extractor.compute(img, keypoints);
    %
    % See also: cv.FeatureDetector, cv.BOWImgDescriptorExtractor
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
            %       * 'BRISK' cv.BRISK
            %       * 'ORB' cv.ORB (default)
            %       * 'KAZE' cv.KAZE
            %       * 'AKAZE' cv.AKAZE
            %       * 'SIFT' cv.SIFT (requires `xfeatures2d` module)
            %       * 'SURF' cv.SURF (requires `xfeatures2d` module)
            %       * 'FREAK' cv.FREAK (requires `xfeatures2d` module)
            %       * 'BriefDescriptorExtractor' cv.BriefDescriptorExtractor (requires `xfeatures2d` module)
            %       * 'LUCID' cv.LUCID (requires `xfeatures2d` module)
            %       * 'LATCH' cv.LATCH (requires `xfeatures2d` module)
            %       * 'DAISY' cv.DAISY (requires `xfeatures2d` module)
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
            typename = DescriptorExtractor_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.DescriptorExtractor.empty
            %
            DescriptorExtractor_(this.id, 'clear');
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
            % See also: cv.DescriptorExtractor.save, cv.DescriptorExtractor.load
            %
            name = DescriptorExtractor_(this.id, 'getDefaultName');
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
            % See also: cv.DescriptorExtractor.load
            %
            DescriptorExtractor_(this.id, 'save', filename);
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
            % See also: cv.DescriptorExtractor.save
            %
            DescriptorExtractor_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.DescriptorExtractor.clear
            %
            b = DescriptorExtractor_(this.id, 'empty');
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
            n = DescriptorExtractor_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = DescriptorExtractor_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = DescriptorExtractor_(this.id, 'descriptorType');
        end

        function [descriptors, keypoints] = compute(this, image, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = extractor.compute(image, keypoints)
            %    [descriptors, keypoints] = extractor.compute(images, keypoints)
            %
            % ## Input
            % * __image__ Image.
            % * __images__ Image set.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example: cv.SIFT
            %       duplicates keypoint with several dominant orientations
            %       (for each orientation).
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
            %       In the second variant of the method `keypoints{i}` are the
            %       set of keypoints corresponding to `images{i}`.
            %
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %       the method `descriptors{i}` are descriptors computed for a
            %       `keypoints(i)`. Row `j` in `descriptors` (or
            %       `descriptors{i}`) is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints,
            %       for which descriptors have been computed.
            %
            % See also cv.DescriptorExtractor
            %
            [descriptors, keypoints] = DescriptorExtractor_(this.id, 'compute', image, keypoints);
        end
    end

end
