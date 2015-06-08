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
            typename = SimpleBlobDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.SimpleBlobDetector.empty
            %
            SimpleBlobDetector_(this.id, 'clear');
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
            % See also: cv.SimpleBlobDetector.save, cv.SimpleBlobDetector.load
            %
            name = SimpleBlobDetector_(this.id, 'getDefaultName');
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
            % See also: cv.SimpleBlobDetector.load
            %
            SimpleBlobDetector_(this.id, 'save', filename);
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
            % See also: cv.SimpleBlobDetector.save
            %
            SimpleBlobDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SimpleBlobDetector.clear
            %
            b = SimpleBlobDetector_(this.id, 'empty');
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
            n = SimpleBlobDetector_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = SimpleBlobDetector_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = SimpleBlobDetector_(this.id, 'descriptorType');
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
            % See also: cv.SimpleBlobDetector.SimpleBlobDetector
            %
            keypoints = SimpleBlobDetector_(this.id, 'detect', image, varargin{:});
        end
    end

end
