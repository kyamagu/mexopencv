classdef AKAZE < handle
    %AKAZE  Class implementing the AKAZE keypoint detector and descriptor extractor
    %
    % As described in [ANB13].
    %
    % Note: AKAZE descriptors can only be used with KAZE or AKAZE keypoints.
    %
    % ## References:
    % [ANB13]:
    % > "Fast Explicit Diffusion for Accelerated Features in Nonlinear Scale Spaces".
    % > Pablo F. Alcantarilla, Jesus Nuevo and Adrien Bartoli.
    % > In British Machine Vision Conference (BMVC), Bristol, UK, Sept 2013.
    %
    % See also: cv.AKAZE.AKAZE, cv.KAZE, cv.FeatureDetector,
    %   cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Type of the extracted descriptor.
        %
        % One of:
        %
        % * __KAZE__
        % * __KAZEUpright__ Upright descriptors, not invariant to rotation.
        % * __MLDB__ (default)
        % * __MLDBUpright__ Upright descriptors, not invariant to rotation.
        DescriptorType
        % Size of the descriptor in bits.
        %
        % 0 -> Full size. Default 0
        DescriptorSize
        % Number of channels in the descriptor (1, 2, 3).
        %
        % Default 3
        DescriptorChannels
        % Detector response threshold to accept point.
        %
        % Default 0.001
        Threshold
        % Maximum octave evolution of the image.
        %
        % Default 4
        NOctaves
        % Default number of sublevels per scale level.
        %
        % Default 4
        NOctaveLayers
        % Diffusivity type.
        %
        % One of:
        %
        % * __PM_G1__
        % * __PM_G2__ (default)
        % * __WEICKERT__
        % * __CHARBONNIER__
        Diffusivity
    end

    methods
        function this = AKAZE(varargin)
            %AKAZE  The AKAZE constructor.
            %
            %    obj = cv.AKAZE()
            %    obj = cv.AKAZE(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __DescriptorType__ See cv.AKAZE.DescriptorType, default 'MLDB'
            % * __DescriptorSize__ See cv.AKAZE.DescriptorSize, default 0
            % * __DescriptorChannels__ See cv.AKAZE.DescriptorChannels,
            %       default 3
            % * __Threshold__ See cv.AKAZE.Threshold, default 0.001
            % * __NOctaves__ See cv.AKAZE.NOctaves, default 4
            % * __NOctaveLayers__ See cv.AKAZE.NOctaveLayers, default 4
            % * __Diffusivity__ See cv.AKAZE.Diffusivity, default 'PM_G2'
            %
            % See also: cv.AKAZE.detectAndCompute
            %
            this.id = AKAZE_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.AKAZE
            %
            AKAZE_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = AKAZE_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.AKAZE.empty, cv.AKAZE.load
            %
            AKAZE_(this.id, 'clear');
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
            % See also: cv.AKAZE.clear, cv.AKAZE.load
            %
            b = AKAZE_(this.id, 'empty');
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
            % See also: cv.AKAZE.load
            %
            AKAZE_(this.id, 'save', filename);
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
            % See also: cv.AKAZE.save
            %
            AKAZE_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.AKAZE.save, cv.AKAZE.load
            %
            name = AKAZE_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector + DescriptorExtractor
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
            % `L2` when cv.AKAZE.DescriptorType is 'KAZE' or 'KAZEUpright',
            % otherwise 'Hamming' for 'MLDB' and 'MLDBUpright'.
            %
            % See also: cv.AKAZE.compute, cv.DescriptorMatcher
            %
            ntype = AKAZE_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in floats/bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % 64 when cv.AKAZE.DescriptorType is 'KAZE' or 'KAZEUpright',
            % otherwise for 'MLDB' and 'MLDBUpright' the size depends on
            % cv.AKAZE.DescriptorSize and cv.AKAZE.DescriptorChannels.
            %
            % See also: cv.AKAZE.descriptorType, cv.AKAZE.compute
            %
            sz = AKAZE_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % `single` when cv.AKAZE.DescriptorType is 'KAZE' or 'KAZEUpright',
            % otherwise 'uint8' for 'MLDB' and 'MLDBUpright'.
            %
            % See also: cv.AKAZE.descriptorSize, cv.AKAZE.compute
            %
            dtype = AKAZE_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(img)
            %    keypoints = obj.detect(imgs)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image.
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. In the first variant,
            %       a 1-by-N structure array. In the second variant of the
            %       method, `keypoints{i}` is a set of keypoints detected in
            %       `imgs{i}`.
            %
            % ## Options
            % * __Mask__ A mask specifying where to look for keypoints
            %       (optional). It must be a logical or 8-bit integer matrix
            %       with non-zero values in the region of interest. In the
            %       second variant, it is a cell-array of masks for each input
            %       image, `masks{i}` is a mask for `imgs{i}`.
            %       Not set by default.
            %
            % See also: cv.AKAZE.compute, cv.AKAZE.detectAndCompute
            %
            keypoints = AKAZE_(this.id, 'detect', img, varargin{:});
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
            % See also: cv.AKAZE.detect, cv.AKAZE.detectAndCompute
            %
            [descriptors, keypoints] = AKAZE_(this.id, 'compute', img, keypoints);
        end

        function [keypoints, descriptors] = detectAndCompute(this, img, varargin)
            %DETECTANDCOMPUTE  Detects keypoints and computes their descriptors
            %
            %    [keypoints, descriptors] = obj.detectAndCompute(img)
            %    [...] = obj.detectAndCompute(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image, input 8-bit grayscale image. Internally image
            %       is converted to 32-bit floating-point in the [0,1] range.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. A 1-by-N structure array
            %       with the following fields:
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
            % * __descriptors__ Computed descriptors. Output concatenated
            %       vectors of descriptors. Each descriptor is a vector of
            %       length cv.AKAZE.descriptorSize, so the total size of
            %       descriptors will be `numel(keypoints) * obj.descriptorSize()`.
            %       A matrix of size N-by-sz, one row per keypoint.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %       Not set by default.
            % * __Keypoints__ If passed, then the method will use the provided
            %       vector of keypoints instead of detecting them, and the
            %       algorithm just computes their descriptors.
            %
            % See also: cv.AKAZE.detect, cv.AKAZE.compute
            %
            [keypoints, descriptors] = AKAZE_(this.id, 'detectAndCompute', img, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.DescriptorType(this)
            value = AKAZE_(this.id, 'get', 'DescriptorType');
        end
        function set.DescriptorType(this, value)
            AKAZE_(this.id, 'set', 'DescriptorType', value);
        end

        function value = get.DescriptorSize(this)
            value = AKAZE_(this.id, 'get', 'DescriptorSize');
        end
        function set.DescriptorSize(this, value)
            AKAZE_(this.id, 'set', 'DescriptorSize', value);
        end

        function value = get.DescriptorChannels(this)
            value = AKAZE_(this.id, 'get', 'DescriptorChannels');
        end
        function set.DescriptorChannels(this, value)
            AKAZE_(this.id, 'set', 'DescriptorChannels', value);
        end

        function value = get.Threshold(this)
            value = AKAZE_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            AKAZE_(this.id, 'set', 'Threshold', value);
        end

        function value = get.NOctaves(this)
            value = AKAZE_(this.id, 'get', 'NOctaves');
        end
        function set.NOctaves(this, value)
            AKAZE_(this.id, 'set', 'NOctaves', value);
        end

        function value = get.NOctaveLayers(this)
            value = AKAZE_(this.id, 'get', 'NOctaveLayers');
        end
        function set.NOctaveLayers(this, value)
            AKAZE_(this.id, 'set', 'NOctaveLayers', value);
        end

        function value = get.Diffusivity(this)
            value = AKAZE_(this.id, 'get', 'Diffusivity');
        end
        function set.Diffusivity(this, value)
            AKAZE_(this.id, 'set', 'Diffusivity', value);
        end
    end

end
