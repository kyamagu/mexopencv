classdef GeneralizedHoughBallard < handle
    %GENERALIZEDHOUGHBALLARD  Generalized Hough transform
    %
    % Finds arbitrary template in the grayscale image using
    % Generalized Hough Transform.
    %
    % Detects position only without translation and rotation.
    %
    % ## References
    % > Ballard, D.H. (1981). Generalizing the Hough transform to detect
    % > arbitrary shapes. Pattern Recognition 13 (2): 111-122.
    %
    % See also: cv.GeneralizedHoughGuil
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Canny low threshold. default 50
        CannyLowThresh
        % Canny high threshold. default 100
        CannyHighThresh
        % Minimum distance between the centers of the detected objects.
        % default 1.0
        MinDist
        % Inverse ratio of the accumulator resolution to the image resolution.
        % default 1.0
        Dp
        % Maximal size of inner buffers. default 1000
        MaxBufferSize

        % R-Table levels. default 360
        Levels
        % The accumulator threshold for the template centers at the detection
        % stage. The smaller it is, the more false positions may be detected.
        % default 100
        VotesThreshold
    end

    %% GeneralizedHoughBallard
    methods
        function this = GeneralizedHoughBallard()
            %GENERALIZEDHOUGHBALLARD  Constructor
            %
            %     obj = cv.GeneralizedHoughBallard()
            %
            % See also: cv.GeneralizedHoughBallard.detect
            %
            this.id = GeneralizedHoughBallard_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.GeneralizedHoughBallard
            %
            if isempty(this.id), return; end
            GeneralizedHoughBallard_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.GeneralizedHoughBallard.empty,
            %  cv.GeneralizedHoughBallard.load
            %
            GeneralizedHoughBallard_(this.id, 'clear');
        end

        function load(this, filename, varargin)
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
            % See also: cv.GeneralizedHoughBallard.save
            %
            GeneralizedHoughBallard_(this.id, 'load', filename, varargin{:});
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
            % See also: cv.GeneralizedHoughBallard.load
            %
            GeneralizedHoughBallard_(this.id, 'save', filename);
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.GeneralizedHoughBallard.clear,
            %  cv.GeneralizedHoughBallard.load
            %
            b = GeneralizedHoughBallard_(this.id, 'empty');
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
            % See also: cv.GeneralizedHoughBallard.save,
            %  cv.GeneralizedHoughBallard.load
            %
            name = GeneralizedHoughBallard_(this.id, 'getDefaultName');
        end
    end

    %% GeneralizedHough
    methods
        function [positions,votes] = detect(this, varargin)
            %DETECT  Find template on image
            %
            %     [positions,votes] = hough.detect(image)
            %     [positions,votes] = hough.detect(edges, dx, dy)
            %
            % ## Input
            % * __image__ input image, 8-bit 1-channel image
            % * __edges__ image edges
            % * __dx__ image x-derivative of the same size as `edges` and
            %   single-precision floating type.
            % * __dy__ image y-derivate of the same size and type as `dx`.
            %
            % ## Output
            % * __positions__ Cell array of 4-element vectors, each of the
            %   form: `[posx, posy, scale, angle]`
            % * __votes__ Cell array of 3-element vectors, of the same length
            %   as `positions`.
            %
            [positions,votes] = GeneralizedHoughBallard_(this.id, 'detect', varargin{:});
        end

        function setTemplate(this, varargin)
            %SETTEMPLATE  Set template to search
            %
            %     hough.setTemplate(templ)
            %     hough.setTemplate(edges, dx, dy)
            %     hough.setTemplate(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __templ__ template, 8-bit 1-channel image
            % * __edges__ template edges
            % * __dx__ template x-derivative of the same size as `edges` and
            %   single-precision floating type.
            % * __dy__ template y-derivate of the same size and type as `dx`.
            %
            % ## Options
            % * __Center__ Template center `[x,y]`. The default `[-1,-1]`
            %   will use `[size(templ,2) size(templ,1)]./2` as center.
            %
            % In the first variant of the function (with the `templ` input),
            % the `edges` are internally calculated using the cv.Canny filter,
            % and the derivatives `dx` and `dy` using cv.Sobel operator.
            %
            GeneralizedHoughBallard_(this.id, 'setTemplate', varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.CannyHighThresh(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'CannyHighThresh');
        end
        function set.CannyHighThresh(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'CannyHighThresh', value);
        end

        function value = get.CannyLowThresh(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'CannyLowThresh');
        end
        function set.CannyLowThresh(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'CannyLowThresh', value);
        end

        function value = get.Dp(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'Dp');
        end
        function set.Dp(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'Dp', value);
        end

        function value = get.MaxBufferSize(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'MaxBufferSize');
        end
        function set.MaxBufferSize(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'MaxBufferSize', value);
        end

        function value = get.MinDist(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'MinDist');
        end
        function set.MinDist(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'MinDist', value);
        end

        function value = get.Levels(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'Levels');
        end
        function set.Levels(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'Levels', value);
        end

        function value = get.VotesThreshold(this)
            value = GeneralizedHoughBallard_(this.id, 'get', 'VotesThreshold');
        end
        function set.VotesThreshold(this, value)
            GeneralizedHoughBallard_(this.id, 'set', 'VotesThreshold', value);
        end
    end

end
