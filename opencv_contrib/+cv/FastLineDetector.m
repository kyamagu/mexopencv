classdef FastLineDetector < handle
    %FASTLINEDETECTOR  Class implementing the FLD (Fast Line Detector) algorithm
    %
    % As described in [Lee14].
    %
    % ## References
    % [Lee14]:
    % > Jin Han Lee, Sehyung Lee, Guoxuan Zhang, Jongwoo Lim, Wan Kyun Chung,
    % > and Il Hong Suh. "Outdoor place recognition in urban environments
    % > using straight lines". In 2014 IEEE International Conference on
    % > Robotics and Automation (ICRA), pages 5550-5557. IEEE, 2014.
    %
    % See also: cv.FastLineDetector.FastLineDetector, cv.LineSegmentDetector,
    %  cv.HoughLines, houghlines
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = FastLineDetector(varargin)
            %FASTLINEDETECTOR  Creates a FastLineDetector object and initializes it
            %
            %     obj = cv.FastLineDetector()
            %     obj = cv.FastLineDetector('OptionName',optionValue, ...)
            %
            % ## Options
            % * __LengthThreshold__ Segment shorter than this will be
            %   discarded. default 10
            % * __DistanceThreshold__ A point placed from a hypothesis line
            %   segment farther than this will be regarded as an outlier.
            %   default 1.41421356
            % * __CannyThreshold1__ First threshold for hysteresis procedure
            %   in cv.Canny. default 50
            % * __CannyThreshold2__ Second threshold for hysteresis procedure
            %   in cv.Canny. default 50
            % * __CannyApertureSize__ Aperturesize for the sobel operator in
            %   cv.Canny. default 3
            % * __DoMerge__ If true, incremental merging of segments will be
            %   perfomred. default false
            %
            % See also: cv.FastLineDetector.detect
            %
            this.id = FastLineDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.FastLineDetector
            %
            if isempty(this.id), return; end
            FastLineDetector_(this.id, 'delete');
        end
    end

    %% FastLineDetector
    methods
        function lines = detect(this, img)
            %DETECT  Finds lines in the input image
            %
            %     lines = obj.detect(img)
            %
            % ## Input
            % * __img__ A grayscale (`uint8`) input image.
            %
            % ## Output
            % * __lines__ A cell array of 4-elements vectors of the form
            %   `{[x1,y1, x2,y2], ..}` specifying the beginning and ending
            %   point of a line, where point 1 `[x1,y1]` is the start, point 2
            %   `[x2,y2]` the end. Returned lines are directed so that the
            %   brighter side is on their left.
            %
            % An example output of the default parameters of the algorithm can
            % be seen here:
            %
            % ![image](https://docs.opencv.org/3.3.1/corridor_fld.jpg)
            %
            % If only a ROI needs to be selected, use:
            %
            %     lines = obj.detect(cv.Rect.crop(image, roi));
            %     lines = cat(1, lines{:});
            %     lines = bsxfun(@plus, lines, roi);
            %
            % See also: cv.FastLineDetector.drawSegments
            %
            lines = FastLineDetector_(this.id, 'detect', img);
        end

        function img = drawSegments(this, img, lines, varargin)
            %DRAWSEGMENTS  Draws the line segments on a given image
            %
            %     img = obj.drawSegments(img, lines)
            %     img = obj.drawSegments(img, lines, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ The image, where the lines will be drawn. Should be
            %   bigger or equal to the image, where the lines were found.
            % * __lines__ A vector of the lines that needed to be drawn.
            %
            % ## Output
            % * __img__ Output image with drawn line segments.
            %
            % ## Options
            % * __DrawArrow__ If true, arrow heads will be drawn. default false
            %
            % See also: cv.FastLineDetector.detect
            %
            img = FastLineDetector_(this.id, 'drawSegments', img, lines, varargin{:});
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.FastLineDetector.empty, cv.FastLineDetector.load
            %
            FastLineDetector_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.FastLineDetector.clear, cv.FastLineDetector.load
            %
            b = FastLineDetector_(this.id, 'empty');
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
            % See also: cv.FastLineDetector.load
            %
            FastLineDetector_(this.id, 'save', filename);
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
            % See also: cv.FastLineDetector.save
            %
            FastLineDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.FastLineDetector.save, cv.FastLineDetector.load
            %
            name = FastLineDetector_(this.id, 'getDefaultName');
        end
    end

end
