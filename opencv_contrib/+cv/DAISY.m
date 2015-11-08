classdef DAISY < handle
    %DAISY  Class implementing DAISY descriptor.
    %
    % As described in [Tola10].
    %
    % ## References:
    % [Tola10]:
    % > E. Tola, V. Lepetit, and P. Fua.
    % > "DAISY: An Efficient Dense Descriptor Applied to Wide Baseline Stereo".
    % > IEEE Transactions on Pattern Analysis and Machine Intelligence,
    % > 32(5):815-830, May 2010.
    %
    % See also: cv.DAISY.DAISY, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = DAISY(varargin)
            %DAISY  Constructor
            %
            %    obj = cv.DAISY()
            %    obj = cv.DAISY(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Radius__ radius of the descriptor at the initial scale.
            %       default 15
            % * __RadiusQuant__ amount of radial range division quantity.
            %       default 3
            % * __AngleQuant__ amount of angular range division quantity.
            %       default 8
            % * __GradOrientationsQuant__ amount of gradient orientations
            %       range division quantity. default 8
            % * __Normalization__ choose descriptors normalization type, where
            %       * __None__ will not do any normalization (default)
            %       * __Partial__ mean that histograms are normalized
            %             independently for L2 norm equal to 1.0
            %       * __Full__ mean that descriptors are normalized for L2
            %             norm equal to 1.0
            %       * __SIFT__ mean that descriptors are normalized for L2
            %             norm equal to 1.0 but no individual one is bigger
            %             than 0.154 as in SIFT
            % * __H__ optional 3x3 homography matrix used to warp the grid of
            %       daisy but sampling keypoints remains unwarped on image.
            %       default empty
            % * __Interpolation__ switch to disable interpolation for speed
            %       improvement at minor quality loss. default true
            % * __UseOrientation__ sample patterns using keypoints
            %       orientation, disabled by default. default false
            %
            % See also: cv.DAISY.compute
            %
            this.id = DAISY_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.DAISY
            %
            DAISY_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = DAISY_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.DAISY.empty, cv.DAISY.load
            %
            DAISY_(this.id, 'clear');
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
            % See also: cv.DAISY.clear
            %
            b = DAISY_(this.id, 'empty');
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
            % See also: cv.DAISY.load
            %
            DAISY_(this.id, 'save', filename);
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
            % See also: cv.DAISY.save
            %
            DAISY_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.DAISY.save, cv.DAISY.load
            %
            name = DAISY_(this.id, 'getDefaultName');
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
            % Always `L2` for FREAK.
            %
            % See also: cv.DAISY.compute, cv.DescriptorMatcher
            %
            ntype = DAISY_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in floats
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % See also: cv.DAISY.descriptorType, cv.DAISY.compute
            %
            sz = DAISY_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `single` for DAISY.
            %
            % See also: cv.DAISY.descriptorSize, cv.DAISY.compute
            %
            dtype = DAISY_(this.id, 'descriptorType');
        end

        function [descriptors, keypoints] = compute(this, img, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = obj.compute(img, keypoints)
            %    [descriptors, keypoints] = obj.compute(imgs, keypoints)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image. Input
            %       image is internally converted to 32-bit floating-point in
            %       [0,1] range.
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
            % See also: cv.DAISY.DAISY, cv.DAISY.compute_all
            %
            [descriptors, keypoints] = DAISY_(this.id, 'compute', img, keypoints);
        end
    end

    %% DAISY
    methods
        function descriptors = compute_all(this, image, varargin)
            %COMPUTE_ALL  Compute all descriptors of an image
            %
            %    descriptors = obj.compute_all(image)
            %    descriptors = obj.compute_all(image, roi)
            %
            % ## Input
            % * __image__ image to extract descriptors.
            % * __roi__ optional region of interest within image
            %       `[x,y,width,height]`.
            %
            % ## Output
            % * __descriptors__ In the first variant, descriptors are computed
            %       for all image pixels. In the second variant, resulted
            %       descriptors array for ROI image pixels.
            %
            % See also: cv.DAISY.compute
            %
            descriptors = DAISY_(this.id, 'compute_all', image, varargin{:});
        end

        function descriptor = GetDescriptor(this, y, x, orientation, varargin)
            %GETDESCRIPTOR  Compute descriptor for the specified position.
            %
            %    descriptor = obj.GetDescriptor(y, x, orientation)
            %    [...] = obj.GetDescriptor(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __y__ position y on image.
            % * __x__ position x on image.
            % * __orientation__ orientation on image (0->360).
            %
            % ## Output
            % * __descriptor__ Output descriptor array computed at pixel.
            %
            % ## Options
            % * __H__ optional 3x3 homography matrix for warped grid.
            %       Not set by default
            % * __Unnormalized__ set to return the unnormalized descriptor.
            %       default false
            %
            % See also: cv.DAISY.compute
            %
            descriptor = DAISY_(this.id, 'GetDescriptor', y, x, orientation, varargin{:});
        end
    end

end
