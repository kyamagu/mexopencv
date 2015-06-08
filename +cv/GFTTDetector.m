classdef GFTTDetector < handle
    %GFTTDETECTOR  Wrapping class for feature detection using the goodFeaturesToTrack function.
    %
    % ## References:
    % [Shi94]:
    % > Jianbo Shi and Carlo Tomasi. "Good features to track".
    % > In Computer Vision and Pattern Recognition, 1994. Proceedings CVPR'94.,
    % > 1994 IEEE Computer Society Conference on, pages 593-600. IEEE, 1994.
    %
    % See also: cv.goodFeaturesToTrack
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Maximum number of corners to return. If there are more corners than
        % are found, the strongest of them is returned.
        MaxFeatures
        % Parameter characterizing the minimal accepted quality of image
        % corners. The parameter value is multiplied by the best corner
        % quality measure, which is the minimal eigenvalue (see
        % cv.cornerMinEigenVal) or the Harris function response (see
        % cv.cornerHarris). The corners with the quality measure less than the
        % product are rejected. For example, if the best corner has the
        % quality measure = 1500, and the `QualityLevel=0.01`, then all the
        % corners with the quality measure less than 15 are rejected.
        QualityLevel
        % Minimum possible Euclidean distance between the returned corners.
        MinDistance
        % Size of an average block for computing a derivative covariation
        % matrix over each pixel neighborhood. See cv.cornerEigenValsAndVecs.
        BlockSize
        % Parameter indicating whether to use a Harris detector
        % (see cv.cornerHarris) or cv.cornerMinEigenVal
        HarrisDetector
        % Free parameter of the Harris detector.
        K
    end

    methods
        function this = GFTTDetector(varargin)
            %GFTTDETECTOR  Constructor
            %
            %    obj = cv.GFTTDetector()
            %    obj = cv.GFTTDetector(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __MaxCorners__ default 1000
            % * __QualityLevel__ default 0.01
            % * __MinDistance__ default 1
            % * __BlockSize__ default 3
            % * __UseHarrisDetector__ default false
            % * __K__ default 0.04
            %
            % See also: cv.GFTTDetector.detect
            %
            this.id = GFTTDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.GFTTDetector
            %
            GFTTDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = GFTTDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.GFTTDetector.empty
            %
            GFTTDetector_(this.id, 'clear');
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
            % See also: cv.GFTTDetector.save, cv.GFTTDetector.load
            %
            name = GFTTDetector_(this.id, 'getDefaultName');
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
            % See also: cv.GFTTDetector.load
            %
            GFTTDetector_(this.id, 'save', filename);
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
            % See also: cv.GFTTDetector.save
            %
            GFTTDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.GFTTDetector.clear
            %
            b = GFTTDetector_(this.id, 'empty');
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
            n = GFTTDetector_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = GFTTDetector_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = GFTTDetector_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, image, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(image)
            %    keypoints = obj.detect(images)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Inputs
            % * __image__ Image, input 8-bit integer or 32-bit floating-point,
            %       single-channel image.
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
            % See also: cv.GFTTDetector.GFTTDetector
            %
            keypoints = GFTTDetector_(this.id, 'detect', image, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.MaxFeatures(this)
            value = GFTTDetector_(this.id, 'get', 'MaxFeatures');
        end
        function set.MaxFeatures(this, value)
            GFTTDetector_(this.id, 'set', 'MaxFeatures', value);
        end

        function value = get.QualityLevel(this)
            value = GFTTDetector_(this.id, 'get', 'QualityLevel');
        end
        function set.QualityLevel(this, value)
            GFTTDetector_(this.id, 'set', 'QualityLevel', value);
        end

        function value = get.MinDistance(this)
            value = GFTTDetector_(this.id, 'get', 'MinDistance');
        end
        function set.MinDistance(this, value)
            GFTTDetector_(this.id, 'set', 'MinDistance', value);
        end

        function value = get.BlockSize(this)
            value = GFTTDetector_(this.id, 'get', 'BlockSize');
        end
        function set.BlockSize(this, value)
            GFTTDetector_(this.id, 'set', 'BlockSize', value);
        end

        function value = get.HarrisDetector(this)
            value = GFTTDetector_(this.id, 'get', 'HarrisDetector');
        end
        function set.HarrisDetector(this, value)
            GFTTDetector_(this.id, 'set', 'HarrisDetector', value);
        end

        function value = get.K(this)
            value = GFTTDetector_(this.id, 'get', 'K');
        end
        function set.K(this, value)
            GFTTDetector_(this.id, 'set', 'K', value);
        end
    end

end
