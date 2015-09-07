classdef LineSegmentDetector < handle
    %LINESEGMENTDETECTOR  Line segment detector class.
    %
    % Following the algorithm described at [Rafael12].
    %
    % ## References:
    % [Rafael12]:
    % > Rafael Grompone von Gioi, Jeremie Jakubowicz, Jean-Michel Morel,
    % > and Gregory Randall. Lsd: a line segment detector. 2012.
    %

    properties (SetAccess = private)
        id  % Object ID
    end

    methods
        function this = LineSegmentDetector(varargin)
            %LINESEGMENTDETECTOR  Creates a LineSegmentDetector object and initializes it.
            %
            %    lsd = cv.LineSegmentDetector()
            %    lsd = cv.LineSegmentDetector('OptionName', optionValue, ...)
            %
            % ## Options
            % * __Refine__ The way found lines will be refined, one of:
            %       * __None__  No refinement applied.
            %       * __Standard__ (default) Standard refinement is applied.
            %             E.g. breaking arches into smaller straighter line
            %             approximations.
            %       * __Advanced__ Advanced refinement. Number of false alarms
            %             is calculated, lines are refined through increase of
            %             precision, decrement in size, etc.
            % * __Scale__ The scale of the image that will be used to find the
            %       lines. In the range `[0,1)`. default 0.8
            % * __SigmaScale__ Sigma for Gaussian filter. It is computed as
            %       `sigma = SigmaScale/Scale`. default 0.6
            % * __QuantError__ Bound to the quantization error on the gradient
            %       norm. default 2.0
            % * __AngleTol__ Gradient angle tolerance in degrees. default 22.5
            % * __DetectionThreshold__ Detection threshold:
            %       `-log10(NFA) > DetectionThreshold`. Used only when
            %       advancent refinement is chosen. default 0
            % * __MinDensity__ Minimal density of aligned region points in the
            %       enclosing rectangle. default 0.7
            % * __NBins__ Number of bins in pseudo-ordering of gradient
            %       modulus. default 1024
            %
            % The cv.LineSegmentDetector algorithm is defined using the
            % standard values. Only advanced users may want to edit those, as
            % to tailor it for their own application.
            %
            this.id = LineSegmentDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.LineSegmentDetector
            %
            LineSegmentDetector_(this.id, 'delete');
        end
    end

    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.LineSegmentDetector.empty
            %
            LineSegmentDetector_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if algorithm object is empty.
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm object is empty
            %       (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.LineSegmentDetector.clear
            %
            b = LineSegmentDetector_(this.id, 'empty');
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
            % See also: cv.LineSegmentDetector.save, cv.LineSegmentDetector.load
            %
            name = LineSegmentDetector_(this.id, 'getDefaultName');
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
            % See also: cv.LineSegmentDetector.load
            %
            LineSegmentDetector_(this.id, 'save', filename);
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
            % See also: cv.LineSegmentDetector.save
            %
            LineSegmentDetector_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    methods
        function [lines, width, prec, nfa] = detect(this, img)
            %DETECT  Finds lines in the input image.
            %
            %    lines = lsd.detect(img)
            %    [lines, width, prec, nfa] = lsd.detect(img)
            %
            % ## Input
            % * __img__ A grayscale (`uint8`) input image.
            %
            % ## Output
            % * __lines__ A cell-array of 4-element vectors of the form
            %       `{[x1, y1, x2, y2], ..}` specifying the beginning and ending
            %       point of a line. Where point 1 `[x1,y1]` is the start,
            %       point 2 `[x2,y2] the end. Returned lines are strictly
            %       oriented depending on the gradient.
            % * __width__ Vector of widths of the regions, where the lines are
            %       found. E.g. Width of line.
            % * __prec__ Vector of precisions with which the lines are found.
            % * __nfa__ Vector containing number of false alarms in the line
            %       region, with precision of 10%. The bigger the value,
            %       logarithmically better the detection. This vector will be
            %       calculated only when the object refine type is 'Advanced',
            %       empty otherwise.
            %       * -1 corresponds to 10 mean false alarms
            %       * 0 corresponds to 1 mean false alarm
            %       * 1 corresponds to 0.1 mean false alarms
            %
            [lines, width, prec, nfa] = LineSegmentDetector_(this.id, 'detect', img);
        end

        function img = drawSegments(this, img, lines)
            %DRAWSEGMENTS  Draws the line segments on a given image.
            %
            %    img = lsd.drawSegments(img, lines)
            %
            % ## Input
            % * __img__ The image, where the lines will be drawn. Should be
            %       bigger or equal to the image, where the lines were found.
            % * __lines__ A vector of the lines that needed to be drawn.
            %
            % ## Output
            % * __img__ Output image with drawn line segments.
            %
            % See also: cv.LineSegmentDetector.compareSegments
            %
            img = LineSegmentDetector_(this.id, 'drawSegments', img, lines);
        end

        function [img, count] = compareSegments(this, sz, lines1, lines2, varargin)
            %COMPARESEGMENTS  Draws two groups of lines in blue and red, counting the non overlapping (mismatching) pixels.
            %
            %    [img, count] = lsd.compareSegments(sz, lines1, lines2)
            %    [...] = lsd.compareSegments(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __sz__ The size of the image, where `lines1` and `lines2`
            %       were found `[w,h]`.
            % * __lines1__ The first group of lines that needs to be drawn.
            %       It is visualized in blue color.
            % * __lines2__ The second group of lines. They visualized in red
            %       color.
            %
            % ## Output
            % * __img__ color image with the two groups of lines drawn.
            % * __count__ count of non overlapping (mismatching) pixels.
            %
            % ## Options
            % * __Image__ Optional image, where the lines will be drawn. The
            %       image should be color (3-channel) in order for `lines1`
            %       and `lines2` to be drawn in the above mentioned colors.
            %
            % See also: cv.LineSegmentDetector.drawSegments
            %
            [img, count] = LineSegmentDetector_(this.id, 'compareSegments', ...
                sz, lines1, lines2, varargin{:});
        end
    end
end
