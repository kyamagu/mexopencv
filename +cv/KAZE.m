classdef KAZE < handle
    %KAZE  Class implementing the KAZE keypoint detector and descriptor extractor.
    %
    % ## References:
    % [ABD12]:
    % > Pablo Fernandez Alcantarilla, Adrien Bartoli, and Andrew J Davison.
    % > "Kaze features". In European Conference on Computer Vision (ECCV),
    % > Fiorenze, Italy, Oct 2012.
    %
    % See also: cv.AKAZE
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Set to enable extraction of extended (128-byte) descriptor.
        Extended
        % Set to enable use of upright descriptors (non rotation-invariant).
        Upright
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
        function this = KAZE(varargin)
            %KAZE  The KAZE constructor.
            %
            %    obj = cv.KAZE()
            %    obj = cv.KAZE(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Extended__ default false
            % * __Upright__ default false
            % * __Threshold__ default 0.001
            % * __NOctaves__ default 4
            % * __NOctaveLayers__ default 4
            % * __Diffusivity__ default 'PM_G2'
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
            typename = KAZE_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.KAZE.empty
            %
            KAZE_(this.id, 'clear');
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
            % See also: cv.KAZE.save, cv.KAZE.load
            %
            name = KAZE_(this.id, 'getDefaultName');
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
            % See also: cv.KAZE.load
            %
            KAZE_(this.id, 'save', filename);
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
            % See also: cv.KAZE.save
            %
            KAZE_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.KAZE.clear
            %
            b = KAZE_(this.id, 'empty');
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
            n = KAZE_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
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
            dtype = KAZE_(this.id, 'descriptorType');
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
            % See also: cv.KAZE.compute, cv.KAZE.detectAndCompute
            %
            keypoints = KAZE_(this.id, 'detect', image, varargin{:});
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
            % See also: cv.KAZE.detect, cv.KAZE.detectAndCompute
            %
            [descriptors, keypoints] = KAZE_(this.id, 'compute', image, keypoints);
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
            % See also: cv.KAZE.detect, cv.KAZE.compute
            %
            [keypoints, descriptors] = KAZE_(this.id, 'detectAndCompute', image, varargin{:});
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
