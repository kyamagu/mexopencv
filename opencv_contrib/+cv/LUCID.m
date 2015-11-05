classdef LUCID < handle
    %LUCID  Class implementing the Locally Uniform Comparison Image Descriptor.
    %
    % As described in [LUCID].
    %
    % An image descriptor that can be computed very fast, while being about as
    % robust as, for example, cv.SURF or cv.BRIEF.
    %
    % LUCID is a simple description method based on linear time permutation
    % distances between the ordering of RGB values of two image patches.
    % LUCID is computable in linear time with respect to the number of pixels
    % and does not require floating point computation.
    %
    % ## References
    % [LUCID]:
    % > Andrew Ziegler, Eric Christiansen, David Kriegman, Serge J. Belongie.
    % > "Locally Uniform Comparison Image Descriptor".
    % > In Advances in Neural Information Processing Systems, pp. 1-9. 2012.
    %
    % See also: cv.LUCID.LUCID, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = LUCID(varargin)
            %LUCID  Constructor
            %
            %    obj = cv.LUCID()
            %    obj = cv.LUCID(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __LucidKernel__ kernel for descriptor construction, where
            %       1=3x3, 2=5x5, 3=7x7 and so forth. default 1
            % * __BlurKernel__ kernel for blurring image prior to descriptor
            %       construction, where 1=3x3, 2=5x5, 3=7x7 and so forth.
            %       default 2
            %
            % See also: cv.LUCID.compute
            %
            this.id = LUCID_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.LUCID
            %
            LUCID_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = LUCID_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.LUCID.empty
            %
            LUCID_(this.id, 'clear');
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
            % See also: cv.LUCID.clear, cv.LUCID.load
            %
            b = LUCID_(this.id, 'empty');
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
            % See also: cv.LUCID.load
            %
            LUCID_(this.id, 'save', filename);
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
            % See also: cv.LUCID.save
            %
            LUCID_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.LUCID.save, cv.LUCID.load
            %
            name = LUCID_(this.id, 'getDefaultName');
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
            % Always `Hamming` for LUCID.
            %
            % See also: cv.LUCID.compute, cv.DescriptorMatcher
            %
            ntype = LUCID_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size. Depends on `LucidKernel` argument in
            %       constructor.
            %
            % See also: cv.LUCID.descriptorType, cv.LUCID.compute
            %
            sz = LUCID_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `uint8` for LUCID.
            %
            % See also: cv.LUCID.descriptorSize, cv.LUCID.compute
            %
            dtype = LUCID_(this.id, 'descriptorType');
        end

        function [descriptors, keypoints] = compute(this, img, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = obj.compute(img, keypoints)
            %    [descriptors, keypoints] = obj.compute(imgs, keypoints)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit color image.
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
            % See also: cv.LUCID.LUCID
            %
            [descriptors, keypoints] = LUCID_(this.id, 'compute', img, keypoints);
        end
    end

end
