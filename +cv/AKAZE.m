classdef AKAZE < handle
    %AKAZE  Class implementing the AKAZE keypoint detector and descriptor extractor
    %
    % Note: AKAZE descriptors can only be used with KAZE or AKAZE keypoints.
    %
    % ## References:
    % [ANB13]:
    % > "Fast Explicit Diffusion for Accelerated Features in Nonlinear Scale Spaces".
    % > Pablo F. Alcantarilla, Jesus Nuevo and Adrien Bartoli.
    % > In British Machine Vision Conference (BMVC), Bristol, UK, Sept 2013.
    %
    % See also: cv.KAZE
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Type of the extracted descriptor. One of:
        %
        % * __KAZE__
        % * __KAZEUpright__ Upright descriptors, not invariant to rotation.
        % * __MLDB__
        % * __MLDBUpright__ Upright descriptors, not invariant to rotation.
        DescriptorType
        % Size of the descriptor in bits. 0 -> Full size
        DescriptorSize
        % Number of channels in the descriptor (1, 2, 3)
        DescriptorChannels
        % Detector response threshold to accept point
        Threshold
        % Maximum octave evolution of the image
        NOctaves
        % Default number of sublevels per scale level
        NOctaveLayers
        % Diffusivity type. One of:
        %
        % * __PM_G1__
        % * __PM_G2__
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
            % * __DescriptorType__ default 'MLDB'
            % * __DescriptorSize__ default 0
            % * __DescriptorChannels__ default 3
            % * __Threshold__ default 0.001
            % * __NOctaves__ default 4
            % * __NOctaveLayers__ default 4
            % * __Diffusivity__ default 'PM_G2'
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
            typename = AKAZE_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.AKAZE.empty
            %
            AKAZE_(this.id, 'clear');
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
            % See also: cv.AKAZE.save, cv.AKAZE.load
            %
            name = AKAZE_(this.id, 'getDefaultName');
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
            % See also: cv.AKAZE.load
            %
            AKAZE_(this.id, 'save', filename);
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
            % See also: cv.AKAZE.save
            %
            AKAZE_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.AKAZE.clear
            %
            b = AKAZE_(this.id, 'empty');
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
            n = AKAZE_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
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
            dtype = AKAZE_(this.id, 'descriptorType');
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
            % See also: cv.AKAZE.compute, cv.AKAZE.detectAndCompute
            %
            keypoints = AKAZE_(this.id, 'detect', image, varargin{:});
        end

        function [descriptors, keypoints] = compute(this, image, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = obj.compute(image, keypoints)
            %    [descriptors, keypoints] = obj.compute(images, keypoints)
            %
            % ## Inputs
            % * __image__ Image.
            % * __images__ Image set.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example: cv.SIFT
            %       duplicates keypoint with several dominant orientations
            %       (for each orientation).
            %
            % ## Outputs
            % * __descriptors__ Computed descriptors. In the second variant of
            %       the method `descriptors{i}` are descriptors computed for a
            %       `keypoints(i)`. Row `j` in `descriptors` (or
            %       `descriptors{i}`) is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also: cv.AKAZE.detect, cv.AKAZE.detectAndCompute
            %
            [descriptors, keypoints] = AKAZE_(this.id, 'compute', image, keypoints);
        end

        function [keypoints, descriptors] = detectAndCompute(this, image, varargin)
            %DETECTANDCOMPUTE  Detects keypoints and computes the descriptors
            %
            %    [keypoints, descriptors] = obj.detectAndCompute(image)
            %    [...] = obj.detectAndCompute(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __image__ Image.
            %
            % ## Output
            % * __keypoints__ The detected keypoints.
            % * __descriptors__ Computed descriptors.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %       default none
            % * __Keypoints__ If passed, then the method will use the provided
            %       vector of keypoints instead of detecting them.
            %
            % See also: cv.AKAZE.detect, cv.AKAZE.compute
            %
            [keypoints, descriptors] = AKAZE_(this.id, 'detectAndCompute', image, varargin{:});
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
