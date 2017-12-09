classdef LSDDetector < handle
    %LSDDETECTOR  Line Segment Detector
    %
    % ## Lines extraction methodology
    %
    % The lines extraction methodology described in the following is mainly
    % based on [EDL]. The extraction starts with a Gaussian pyramid generated
    % from an original image, downsampled N-1 times, blurred N times, to
    % obtain N layers (one for each octave), with layer 0 corresponding to
    % input image. Then, from each layer (octave) in the pyramid, lines are
    % extracted using LSD algorithm.
    %
    % Differently from `EDLine` lines extractor used in original article, LSD
    % furnishes information only about lines extremes; thus, additional
    % information regarding slope and equation of line are computed via
    % analytic methods. The number of pixels is obtained using
    % cv.LineIterator. Extracted lines are returned in the form of `KeyLine`
    % objects, but since extraction is based on a method different from the
    % one used in cv.BinaryDescriptor class, data associated to a line's
    % extremes in original image and in octave it was extracted from,
    % coincide. `KeyLine`'s field `class_id` is used as an index to indicate
    % the order of extraction of a line inside a single octave.
    %
    % ## References
    % [EDL]:
    % > R Grompone Von Gioi, Jeremie Jakubowicz, Jean-Michel Morel, and
    % > Gregory Randall. "LSD: A fast line segment detector with a false
    % > detection control. IEEE Transactions on Pattern Analysis and Machine
    % > Intelligence, 32(4):722-732, 2010.
    %
    % See also: cv.BinaryDescriptor, cv.drawKeylines,
    %  cv.LineSegmentDetector, cv.LineIterator
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = LSDDetector()
            %LSDDETECTOR  Creates an LSDDetector object
            %
            %     obj = cv.LSDDetector()
            %
            % See also: cv.LSDDetector.detect
            %
            this.id = LSDDetector_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.LSDDetector
            %
            if isempty(this.id), return; end
            LSDDetector_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.LSDDetector.empty, cv.LSDDetector.load
            %
            LSDDetector_(this.id, 'clear');
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
            % See also: cv.LSDDetector.clear
            %
            b = LSDDetector_(this.id, 'empty');
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
            % See also: cv.LSDDetector.load
            %
            LSDDetector_(this.id, 'save', filename);
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
            % See also: cv.LSDDetector.save
            %
            LSDDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.LSDDetector.save, cv.LSDDetector.load
            %
            name = LSDDetector_(this.id, 'getDefaultName');
        end
    end

    %% FeatureDetector
    methods
        function keylines = detect(this, img, varargin)
            %DETECT  Detect lines inside an image or image set
            %
            %     keylines = obj.detect(img)
            %     keylines = obj.detect(imgs)
            %     [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image (first variant), 8-bit grayscale.
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keylines__ Extracted lines for one or more images. In the
            %   first variant, a 1-by-N structure array. In the second
            %   variant of the method, `keylines{i}` is a set of keylines
            %   detected in `imgs{i}`. Each keyline is described with a
            %   `KeyLine` structure with the following fields:
            %   * __angle__ orientation of the line.
            %   * **class_id** object ID, that can be used to cluster keylines
            %     by the line they represent.
            %   * __octave__ octave (pyramid layer), from which the keyline
            %     has been extracted.
            %   * __pt__ coordinates of the middlepoint `[x,y]`.
            %   * __response__ the response, by which the strongest keylines
            %     have been selected. It's represented by the ratio between
            %     line's length and maximum between image's width and height.
            %   * __size__ minimum area containing line.
            %   * __startPoint__ the start point of the line in the original
            %     image `[x,y]`.
            %   * __endPoint__ the end point of the line in the original image
            %     `[x,y]`.
            %   * __startPointInOctave__ the start point of the line in the
            %     octave it was extracted from `[x,y]`.
            %   * __endPointInOctave__ the end point of the line in the octave
            %     it was extracted from `[x,y]`.
            %   * __lineLength__ the length of line.
            %   * __numOfPixels__ number of pixels covered by the line.
            %
            % ## Options
            % * __Scale__ scale factor used in pyramids generation. default 2
            % * __NumOctaves__ number of octaves inside pyramid. default 1
            % * __Mask__ optional mask matrix to detect only `KeyLines` of
            %   interest. It must be a logical or 8-bit integer matrix with
            %   non-zero values in the region of interest. In the second
            %   variant, it is a cell-array of masks for each input image,
            %   `masks{i}` is a mask for `imgs{i}`. Not set by default.
            %
            % `KeyLine` is a struct to represent a line.
            %
            % As aformentioned, it is been necessary to design a class that
            % fully stores the information needed to characterize completely a
            % line and plot it on image it was extracted from, when required.
            %
            % `KeyLine` class has been created for such goal; it is mainly
            % inspired to Feature2d's `KeyPoint` class, since `KeyLine` shares
            % some of `KeyPoint`'s fields, even if a part of them assumes a
            % different meaning, when speaking about lines. In particular:
            %
            % - the `class_id` field is used to gather lines extracted from
            %   different octaves which refer to same line inside original
            %   image (such lines and the one they represent in original image
            %   share the same `class_id` value)
            % - the `angle` field represents line's slope with respect to
            %   (positive) X axis
            % - the `pt` field represents line's midpoint
            % - the `response` field is computed as the ratio between the
            %   line's length and maximum between image's width and height
            % - the `size` field is the area of the smallest rectangle
            %   containing line
            %
            % Apart from fields inspired to `KeyPoint` class, `KeyLines`
            % stores information about extremes of line in original image and
            % in octave it was extracted from, about line's length and number
            % of pixels it covers.
            %
            % See also: cv.LSDDetector.LSDDetector
            %
            keylines = LSDDetector_(this.id, 'detect', img, varargin{:});
        end
    end

end
