classdef SimpleBlobDetector < handle
    %SIMPLEBLOBDETECTOR  Class for extracting blobs from an image.
    %
    % The class implements a simple algorithm for extracting blobs from an
    % image:
    %
    % 1. Convert the source image to binary images by applying thresholding
    %    with several thresholds from `MinThreshold` (inclusive) to
    %    `MaxThreshold` (exclusive) with distance `ThresholdStep` between
    %    neighboring thresholds.
    % 2. Extract connected components from every binary image by
    %    cv.findContours and calculate their centers.
    % 3. Group centers from several binary images by their coordinates. Close
    %    centers form one group that corresponds to one blob, which is
    %    controlled by the `MinDistBetweenBlobs` parameter.
    % 4. From the groups, estimate final centers of blobs and their radiuses
    %    and return as locations and sizes of keypoints.
    %
    % This class performs several filtrations of returned blobs. You should
    % set `FilterBy*` to true/false to turn on/off corresponding filtration.
    % Available filtrations:
    %
    % * **By color**. This filter compares the intensity of a binary image at
    %   the center of a blob to `BlobColor`. If they differ, the blob is
    %   filtered out. Use `BlobColor = 0` to extract dark blobs and
    %   `BlobColor = 255` to extract light blobs.
    % * **By area**. Extracted blobs have an area between `MinArea` (inclusive)
    %   and `MaxArea` (exclusive).
    % * **By circularity**. Extracted blobs have circularity
    %   (`(4*pi*area)/(perimeter*perimeter)`) between `MinCircularity`
    %   (inclusive) and `MaxCircularity` (exclusive).
    % * **By ratio** of the minimum inertia to maximum inertia. Extracted
    %   blobs have this ratio between `MinInertiaRatio` (inclusive) and
    %   `MaxInertiaRatio` (exclusive).
    % * **By convexity**. Extracted blobs have convexity
    %   (area / area of blob convex hull) between `MinConvexity` (inclusive)
    %   and `MaxConvexity` (exclusive).
    %
    % Default values of parameters are tuned to extract dark circular blobs.
    %
    % See also: cv.FeatureDetector
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = SimpleBlobDetector(varargin)
            %SIMPLEBLOBDETECTOR  Constructor
            %
            %    obj = cv.SimpleBlobDetector()
            %    obj = cv.SimpleBlobDetector(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __ThresholdStep__ default 10
            % * __MinThreshold__ default 50
            % * __MaxThreshold__ default 220
            % * __MinRepeatability__ default 2
            % * __MinDistBetweenBlobs__ default 10
            % * __FilterByColor__ default true
            % * __BlobColor__ default 0
            % * __FilterByArea__ default true
            % * __MinArea__ default 25
            % * __MaxArea__ default 5000
            % * __FilterByCircularity__ default false
            % * __MinCircularity__ default 0.8
            % * __MaxCircularity__ default `realmax('single')`
            % * __FilterByInertia__ default true
            % * __MinInertiaRatio__ default 0.1
            % * __MaxInertiaRatio__ default `realmax('single')`
            % * __FilterByConvexity__ default true
            % * __MinConvexity__ default 0.95
            % * __MaxConvexity__ default `realmax('single')`
            %
            % See also: cv.SimpleBlobDetector.detect
            %
            this.id = SimpleBlobDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.SimpleBlobDetector
            %
            SimpleBlobDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = SimpleBlobDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.SimpleBlobDetector.empty,
            %  cv.SimpleBlobDetector.load
            %
            SimpleBlobDetector_(this.id, 'clear');
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
            % See also: cv.SimpleBlobDetector.clear,
            %  cv.SimpleBlobDetector.load
            %
            b = SimpleBlobDetector_(this.id, 'empty');
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
            % See also: cv.SimpleBlobDetector.load
            %
            SimpleBlobDetector_(this.id, 'save', filename);
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
            % See also: cv.SimpleBlobDetector.save
            %
            SimpleBlobDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SimpleBlobDetector.save, cv.SimpleBlobDetector.load
            %
            name = SimpleBlobDetector_(this.id, 'getDefaultName');
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
            %       keypoints (blobs) are detected.
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
            % See also: cv.SimpleBlobDetector.SimpleBlobDetector
            %
            keypoints = SimpleBlobDetector_(this.id, 'detect', img, varargin{:});
        end
    end

end
