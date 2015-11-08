classdef GFTTDetector < handle
    %GFTTDETECTOR  Wrapping class for feature detection using the goodFeaturesToTrack function.
    %
    % The function finds the most prominent corners in the image or in the
    % specified image region, as described in [Shi94]:
    %
    %  1. Function calculates the corner quality measure at every source image
    %     pixel using the cv.cornerMinEigenVal or cv.cornerHarris.
    %  2. Function performs a non-maximum suppression (the local maximums in
    %     `3x3` neighborhood are retained).
    %  3. The corners with the minimal eigenvalue less than
    %     `QualityLevel * max_{x,y}(qualityMeasureMap(x,y))` are rejected.
    %  4. The remaining corners are sorted by the quality measure in the
    %     descending order.
    %  5. Function throws away each corner for which there is a stronger
    %     corner at a distance less than `maxDistance`.
    %
    % ## References:
    % [Shi94]:
    % > Jianbo Shi and Carlo Tomasi. "Good features to track".
    % > In Computer Vision and Pattern Recognition, 1994. Proceedings CVPR'94.,
    % > 1994 IEEE Computer Society Conference on, pages 593-600. IEEE, 1994.
    %
    % See also: cv.goodFeaturesToTrack, cv.cornerHarris, cv.cornerMinEigenVal,
    %  cv.FeatureDetector
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Maximum number of corners to return.
        %
        % If there are more corners than are found, the strongest of them is
        % returned. Default 1000
        MaxFeatures
        % Parameter characterizing the minimal accepted quality of image
        % corners.
        %
        % The parameter value is multiplied by the best corner quality
        % which is the minimal eigenvalue (see cv.cornerMinEigenVal) or the
        % Harris function response (see cv.cornerHarris). The corners with the
        % quality measure less than the product are rejected. For example, if
        % the best corner has the quality measure = 1500, and the
        % `QualityLevel=0.01`, then all the corners with the quality measure
        % less than 15 are rejected. Default 0.01
        QualityLevel
        % Minimum possible Euclidean distance between the returned corners.
        %
        % Default 1.0
        MinDistance
        % Size of an average block for computing a derivative covariation
        % matrix over each pixel neighborhood.
        %
        % See cv.cornerEigenValsAndVecs. Default 3
        BlockSize
        % Parameter indicating whether to use a Harris detector
        % (see cv.cornerHarris) or cv.cornerMinEigenVal.
        %
        % Default false
        HarrisDetector
        % Free parameter of the Harris detector.
        %
        % Default 0.04
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
            % * __MaxFeatures__ See cv.GFTTDetector.MaxFeatures, default 1000
            % * __QualityLevel__ See cv.GFTTDetector.QualityLevel,
            %       default 0.01
            % * __MinDistance__ See cv.GFTTDetector.MinDistance, default 1
            % * __BlockSize__ See cv.GFTTDetector.BlockSize, default 3
            % * __HarrisDetector__ See cv.GFTTDetector.HarrisDetector,
            %       default false
            % * __K__ See cv.GFTTDetector.K, default 0.04
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
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = GFTTDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.GFTTDetector.empty, cv.GFTTDetector.load
            %
            GFTTDetector_(this.id, 'clear');
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
            % See also: cv.GFTTDetector.clear, cv.GFTTDetector.load
            %
            b = GFTTDetector_(this.id, 'empty');
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
            % See also: cv.GFTTDetector.load
            %
            GFTTDetector_(this.id, 'save', filename);
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
            % See also: cv.GFTTDetector.save
            %
            GFTTDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.GFTTDetector.save, cv.GFTTDetector.load
            %
            name = GFTTDetector_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector
    methods
        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(img)
            %    keypoints = obj.detect(imgs)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image where
            %       keypoints (corners) are detected.
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
            % See also: cv.GFTTDetector.GFTTDetector
            %
            keypoints = GFTTDetector_(this.id, 'detect', img, varargin{:});
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
