classdef KAZE < handle
    %KAZE  Class implementing the KAZE keypoint detector and descriptor extractor.
    %
    % As described in [ABD12].
    %
    % Note: AKAZE descriptors can only be used with KAZE or AKAZE keypoints.
    %
    % ## References:
    % [ABD12]:
    % > Pablo Fernandez Alcantarilla, Adrien Bartoli, and Andrew J Davison.
    % > "Kaze features". In European Conference on Computer Vision (ECCV),
    % > Fiorenze, Italy, Oct 2012.
    %
    % See also: cv.KAZE.KAZE, cv.AKAZE, cv.FeatureDetector,
    %   cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Set to enable extraction of extended (128-byte) descriptor.
        %
        % Default false
        Extended
        % Set to enable use of upright descriptors (non rotation-invariant).
        %
        % Default false
        Upright
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
        function this = KAZE(varargin)
            %KAZE  The KAZE constructor.
            %
            %    obj = cv.KAZE()
            %    obj = cv.KAZE(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Extended__ See cv.KAZE.Extended, default false
            % * __Upright__ See cv.KAZE.Upright, default false
            % * __Threshold__ See cv.KAZE.Threshold, default 0.001
            % * __NOctaves__ See cv.KAZE.NOctaves, default 4
            % * __NOctaveLayers__ See cv.KAZE.NOctaveLayers, default 4
            % * __Diffusivity__ See cv.KAZE.Diffusivity, default 'PM_G2'
            %
            % See also: cv.KAZE.detectAndCompute
            %
            this.id = KAZE_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.KAZE
            %
            KAZE_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = KAZE_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.KAZE.empty, cv.KAZE.load
            %
            KAZE_(this.id, 'clear');
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
            % See also: cv.KAZE.clear, cv.KAZE.load
            %
            b = KAZE_(this.id, 'empty');
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
            % See also: cv.KAZE.load
            %
            KAZE_(this.id, 'save', filename);
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
            % See also: cv.KAZE.save
            %
            KAZE_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.KAZE.save, cv.KAZE.load
            %
            name = KAZE_(this.id, 'getDefaultName');
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
            % Always `L2` for KAZE.
            %
            % See also: cv.KAZE.compute, cv.DescriptorMatcher
            %
            ntype = KAZE_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size, either 64 or 128 (see the
            %       cv.KAZE.Extended property).
            %
            % See also: cv.KAZE.descriptorType, cv.KAZE.compute
            %
            sz = KAZE_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `single` for KAZE.
            %
            % See also: cv.KAZE.descriptorSize, cv.KAZE.compute
            %
            dtype = KAZE_(this.id, 'descriptorType');
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
            % See also: cv.KAZE.compute, cv.KAZE.detectAndCompute
            %
            keypoints = KAZE_(this.id, 'detect', img, varargin{:});
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
            % See also: cv.KAZE.detect, cv.KAZE.detectAndCompute
            %
            [descriptors, keypoints] = KAZE_(this.id, 'compute', img, keypoints);
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
            %       vectors of descriptors. Each descriptor is a 64- or
            %       128-element vector, as returned by cv.KAZE.descriptorSize,
            %       so the total size of descriptors will be
            %       `numel(keypoints) * obj.descriptorSize()`. A matrix of
            %       size N-by-(64/128) of class `single`, one row per keypoint.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %       Not set by default.
            % * __Keypoints__ If passed, then the method will use the provided
            %       vector of keypoints instead of detecting them, and the
            %       algorithm just computes their descriptors.
            %
            % See also: cv.KAZE.detect, cv.KAZE.compute
            %
            [keypoints, descriptors] = KAZE_(this.id, 'detectAndCompute', img, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Extended(this)
            value = KAZE_(this.id, 'get', 'Extended');
        end
        function set.Extended(this, value)
            KAZE_(this.id, 'set', 'Extended', value);
        end

        function value = get.Upright(this)
            value = KAZE_(this.id, 'get', 'Upright');
        end
        function set.Upright(this, value)
            KAZE_(this.id, 'set', 'Upright', value);
        end

        function value = get.Threshold(this)
            value = KAZE_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            KAZE_(this.id, 'set', 'Threshold', value);
        end

        function value = get.NOctaves(this)
            value = KAZE_(this.id, 'get', 'NOctaves');
        end
        function set.NOctaves(this, value)
            KAZE_(this.id, 'set', 'NOctaves', value);
        end

        function value = get.NOctaveLayers(this)
            value = KAZE_(this.id, 'get', 'NOctaveLayers');
        end
        function set.NOctaveLayers(this, value)
            KAZE_(this.id, 'set', 'NOctaveLayers', value);
        end

        function value = get.Diffusivity(this)
            value = KAZE_(this.id, 'get', 'Diffusivity');
        end
        function set.Diffusivity(this, value)
            KAZE_(this.id, 'set', 'Diffusivity', value);
        end
    end

end
