classdef MSDDetector < handle
    %MSDDETECTOR  Class implementing the MSD (Maximal Self-Dissimilarity) keypoint detector
    %
    % Maximal Self-Dissimilarity Interest Point Detector, as described in
    % [Tombari14].
    %
    % The algorithm implements a novel interest point detector stemming from
    % the intuition that image patches which are highly dissimilar over a
    % relatively large extent of their surroundings hold the property of being
    % repeatable and distinctive. This concept of "contextual
    % self-dissimilarity" reverses the key paradigm of recent successful
    % techniques such as the Local Self-Similarity descriptor and the
    % Non-Local Means filter, which build upon the presence of similar
    % (rather than dissimilar) patches. Moreover, it extends to contextual
    % information the local self-dissimilarity notion embedded in established
    % detectors of corner-like interest points, thereby achieving enhanced
    % repeatability, distinctiveness and localization accuracy.
    %
    % ## References
    % [Tombari14]:
    % > Federico Tombari and Luigi Di Stefano.
    % > "Interest Points via Maximal Self-Dissimilarities".
    % > In Asian Conference on Computer Vision, ACCV 2014.
    %
    % See also: cv.MSDDetector.MSDDetector, cv.FeatureDetector
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = MSDDetector(varargin)
            %MSDDETECTOR  The full constructor
            %
            %     obj = cv.MSDDetector()
            %     obj = cv.MSDDetector('OptionName',optionValue, ...)
            %
            % ## Options
            % * __PatchRadius__ Patch radius. default 3
            % * __SearchAreaRadius__ Search Area radius. default 5
            % * __NMSRadius__ Non Maxima Suppression spatial radius. default 5
            % * __NMSScaleRadius__ Non Maxima Suppression scale radius.
            %   default 0
            % * __ThSaliency__ Saliency threshold. default 250.0
            % * __KNN__ Number of nearest neighbors. default 4
            % * __ScaleFactor__ Scale factor for building up the image
            %   pyramid. default 1.25
            % * __NScales__ Number of scales number of scales for building up
            %   the image pyramid (if set to -1, this number is automatically
            %   determined). default -1
            % * __ComputeOrientation__ Flag for associating a canoncial
            %   orientation to each keypoint. default false
            %
            % See also: cv.MSDDetector.detect
            %
            this.id = MSDDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.MSDDetector
            %
            if isempty(this.id), return; end
            MSDDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = MSDDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.MSDDetector.empty, cv.MSDDetector.load
            %
            MSDDetector_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.MSDDetector.clear, cv.MSDDetector.load
            %
            b = MSDDetector_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.MSDDetector.load
            %
            MSDDetector_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.MSDDetector.save
            %
            MSDDetector_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.MSDDetector.save, cv.MSDDetector.load
            %
            name = MSDDetector_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector
    methods
        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set
            %
            %     keypoints = obj.detect(img)
            %     keypoints = obj.detect(imgs)
            %     [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale or color image.
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. In the first variant, a
            %   1-by-N structure array. In the second variant of the method,
            %   `keypoints{i}` is a set of keypoints detected in `imgs{i}`.
            %
            % ## Options
            % * __Mask__ A mask specifying where to look for keypoints
            %   (optional). It must be a logical or 8-bit integer matrix with
            %   non-zero values in the region of interest. In the second
            %   variant, it is a cell-array of masks for each input image,
            %   `masks{i}` is a mask for `imgs{i}`. Not set by default.
            %
            % See also: cv.MSDDetector.MSDDetector
            %
            keypoints = MSDDetector_(this.id, 'detect', img, varargin{:});
        end
    end

end
