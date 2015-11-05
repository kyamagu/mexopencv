classdef LATCH < handle
    %LATCH  Class for computing the LATCH descriptor.
    %
    % LATCH is a binary descriptor based on learned comparisons of triplets of
    % image patches.
    %
    % Note: the descriptor can be coupled with any keypoint extractor. The only
    % demand is that if you use set `RotationInvariance = True` then you will
    % have to use an extractor which estimates the patch orientation (in
    % degrees). Examples for such extractors are cv.ORB and cv.SIFT.
    %
    % ## References
    % [2015arXiv150103719L]:
    % > Gil Levi and Tal Hassner,
    % > "LATCH: Learned Arrangements of Three Patch Codes",
    % > arXiv preprint arXiv:1501.03719, 15 Jan. 2015
    %
    % See also: cv.LATCH.LATCH, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = LATCH(varargin)
            %LATCH  Constructor
            %
            %    obj = cv.LATCH()
            %    obj = cv.LATCH(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Bytes__ the size of the descriptor. Can be 64, 32, 16, 8, 4,
            %       2 or 1. default 32
            % * __RotationInvariance__ whether or not the descriptor should
            %       compansate for orientation changes. default true
            % * __HalfSize__ the size of half of the mini-patches size. For
            %       example, if we would like to compare triplets of patches of
            %       size 7x7x then the `half_ssd_size` should be `(7-1)/2 = 3`.
            %       default 3
            %
            % See also: cv.LATCH.compute
            %
            this.id = LATCH_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.LATCH
            %
            LATCH_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = LATCH_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.LATCH.empty, cv.LATCH.load
            %
            LATCH_(this.id, 'clear');
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
            % See also: cv.LATCH.clear, cv.LATCH.load
            %
            b = LATCH_(this.id, 'empty');
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
            % See also: cv.LATCH.load
            %
            LATCH_(this.id, 'save', filename);
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
            % See also: cv.LATCH.save
            %
            LATCH_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.LATCH.save, cv.LATCH.load
            %
            name = LATCH_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: DescriptorExtractor
    methods
        function ntype = defaultNorm(this)
            %DEFAULTNORM  Returns the default norm type
            %
            %    ntype = obj.defaultNorm()
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
            % Always `Hamming` for SURF.
            %
            % See also: cv.LATCH.compute, cv.DescriptorMatcher
            %
            ntype = LATCH_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size, as specified in `Bytes` argument in
            %       constructor.
            %
            % See also: cv.LATCH.descriptorType, cv.LATCH.compute
            %
            sz = LATCH_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `uint8` for LATCH.
            %
            % See also: cv.LATCH.descriptorSize, cv.LATCH.compute
            %
            dtype = LATCH_(this.id, 'descriptorType');
        end

        function [descriptors, keypoints] = compute(this, img, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = obj.compute(img, keypoints)
            %    [descriptors, keypoints] = obj.compute(imgs, keypoints)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image.
            % * __imgs__ Image set (second variant), cell array of images.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example: cv.SIFT
            %       duplicates keypoint with several dominant orientations
            %       (for each orientation). In the first variant, this is a
            %       struct-array of detected keypoints. In the second variant,
            %       it is a cell-array, where `keypoints{i}` is a set of keypoints
            %       detected in `images{i}` (a struct-array like before).
            %
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %       the method `descriptors{i}` are descriptors computed for a
            %       `keypoints{i}`. Row `j` in `descriptors` (or
            %       `descriptors{i}`) is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also: cv.LATCH.LATCH
            %
            [descriptors, keypoints] = LATCH_(this.id, 'compute', img, keypoints);
        end
    end

end
