classdef StarDetector < handle
    %STARDETECTOR  The class implements the Star keypoint detector.
    %
    % ## References:
    % [Agrawal08]:
    % > Motilal Agrawal, Kurt Konolige, and Morten Rufus Blas.
    % > "Censure: Center surround extremas for realtime feature detection and matching".
    % > In Computer Vision-ECCV 2008, pages 102-115. Springer, 2008.
    %
    % See also: cv.StarDetector.StarDetector, cv.FeatureDetector
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = StarDetector(varargin)
            %STARDETECTOR  The full constructor
            %
            %    obj = cv.StarDetector()
            %    obj = cv.StarDetector(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __MaxSize__ maximum size of the features. The following values
            %       are supported: 4, 6, 8, 11, 12, 16, 22, 23, 32, 45, 46, 64,
            %       90, 128. In the case of a different value the result is
            %       undefined. default 45
            % * __ResponseThreshold__ threshold for the approximated laplacian,
            %       used to eliminate weak features. The larger it is, the less
            %       features will be retrieved. default 30
            % * __LineThresholdProjected__ another threshold for the laplacian
            %       to eliminate edges. default 10
            % * __LineThresholdBinarized__ yet another threshold for the
            %       feature size to eliminate edges. The larger the 2nd
            %       threshold, the more points you get. default 8
            % * __SuppressNonmaxSize__ default 5
            %
            % See also: cv.StarDetector.detect
            %
            this.id = StarDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.StarDetector
            %
            StarDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = StarDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.StarDetector.empty, cv.StarDetector.load
            %
            StarDetector_(this.id, 'clear');
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
            % See also: cv.StarDetector.clear
            %
            b = StarDetector_(this.id, 'empty');
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
            % See also: cv.StarDetector.load
            %
            StarDetector_(this.id, 'save', filename);
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
            % See also: cv.StarDetector.save
            %
            StarDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.StarDetector.save, cv.StarDetector.load
            %
            name = StarDetector_(this.id, 'getDefaultName');
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
            % * __img__ Image (first variant), 8-bit/16-bit grayscale image.
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
            % See also: cv.StarDetector.StarDetector
            %
            keypoints = StarDetector_(this.id, 'detect', img, varargin{:});
        end
    end

end
