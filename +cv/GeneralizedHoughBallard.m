classdef GeneralizedHoughBallard < handle
    %GENERALIZEDHOUGHBALLARD  Generalized Hough transform
    %
    % Finds arbitrary template in the grayscale image using
    % Generalized Hough Transform.
    %
    % Detects position only without translation and rotation.
    %
    % ## References:
    % > Ballard, D.H. (1981). Generalizing the Hough transform to detect
    % > arbitrary shapes. Pattern Recognition 13 (2): 111-122.
    %
    % See also: cv.GeneralizedHoughGuil
    %

    properties (SetAccess = private)
        id  % Object ID
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

    methods
        function this = GeneralizedHoughBallard()
            this.id = GeneralizedHoughBallard_(0, 'new');
        end

        function delete(this)
            GeneralizedHoughBallard_(this.id, 'delete');
        end

        function clear(this)
            GeneralizedHoughBallard_(this.id, 'clear');
        end

        function load(this, filename, varargin)
            GeneralizedHoughBallard_(this.id, 'load', filename, varargin{:});
        end

        function save(this, filename)
            GeneralizedHoughBallard_(this.id, 'save', filename);
        end

        function b = empty(this)
            b = GeneralizedHoughBallard_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            name = GeneralizedHoughBallard_(this.id, 'getDefaultName');
        end

        function [positions,votes] = detect(this, varargin)
            %DETECT  Find template on image
            %
            %    [positions,votes] = hough.detect(image)
            %    [positions,votes] = hough.detect(edges, dx, dy)
            %
            % ## Input
            % * __image__ input image, 8-bit 1-channel image
            % * __edges__ image edges
            % * __dx__ image x-derivative of the same size as `edges` and
            %       single-precision floating type.
            % * __dy__ image y-derivate of the same size and type as `dx`.
            %
            % ## Output
            % * __positions__ Cell array of 4-element vectors, each of the
            %        form: `[posx, posy, scale, angle]`
            % * __votes__ Cell array of 3-element vectors, of the same length
            %        as `positions`.
            %
            [positions,votes] = GeneralizedHoughBallard_(this.id, 'detect', varargin{:});
        end

        function setTemplate(this, varargin)
            %SETTEMPLATE  Set template to search
            %
            %    hough.setTemplate(templ)
            %    hough.setTemplate(edges, dx, dy)
            %    hough.setTemplate(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __templ__ template, 8-bit 1-channel image
            % * __edges__ template edges
            % * __dx__ template x-derivative of the same size as `edges` and
            %       single-precision floating type.
            % * __dy__ template y-derivate of the same size and type as `dx`.
            %
            % ## Options
            % * __Center__ Template center `[x,y]`. The default `[-1,-1]`
            %       will use `[size(templ,2) size(templ,1)]./2` as center.
            %
            % In the first variant of the function (with the `templ` input),
            % the `edges` are internally calculated using the cv.Canny filter,
            % and the derivatives `dx` and `dy` using cv.Sobel operator.
            %
            GeneralizedHoughBallard_(this.id, 'setTemplate', varargin{:});
        end
    end

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
