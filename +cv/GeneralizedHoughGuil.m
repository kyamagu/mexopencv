classdef GeneralizedHoughGuil < handle
    %GeneralizedHoughGuil  Generalized Hough transform
    %
    % Finds arbitrary template in the grayscale image using
    % Generalized Hough Transform.
    %
    % Detects position, translation and rotation.
    %
    % ## References
    % > Guil, N., Gonzalez-Linares, J.M. and Zapata, E.L. (1999).
    % > Bidimensional shape detection using an invariant approach.
    % > Pattern Recognition 32 (6): 1025-1038.
    %
    % See also: cv.GeneralizedHoughBallard
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

        % Angle difference in degrees between two points in feature.
        % default 90.0
        Xi
        % Maximal difference between angles that treated as equal. default 1.0
        AngleEpsilon
        % Feature table levels. default 360
        Levels
        % Minimal rotation angle to detect in degrees. default 0.0
        MinAngle
        % Maximal rotation angle to detect in degrees. default 360
        MaxAngle
        % Angle step in degrees. default 1.0
        AngleStep
        % Angle votes threshold. default 15000
        AngleThresh
        % Minimal scale to detect. default 0.5
        MinScale
        % Maximal scale to detect. default 2.0
        MaxScale
        % Scale step. default 0.05
        ScaleStep
        % Scale votes threshold. default 1000
        ScaleThresh
        % Position votes threshold. default 100
        PosThresh
    end

    methods
        function this = GeneralizedHoughGuil()
            this.id = GeneralizedHoughGuil_(0, 'new');
        end

        function delete(this)
            GeneralizedHoughGuil_(this.id, 'delete');
        end

        function clear(this)
            GeneralizedHoughGuil_(this.id, 'clear');
        end

        function load(this, filename, varargin)
            GeneralizedHoughGuil_(this.id, 'load', filename, varargin{:});
        end

        function save(this, filename)
            GeneralizedHoughGuil_(this.id, 'save', filename);
        end

        function b = empty(this)
            b = GeneralizedHoughGuil_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            name = GeneralizedHoughGuil_(this.id, 'getDefaultName');
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
            [positions,votes] = GeneralizedHoughGuil_(this.id, 'detect', varargin{:});
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
            GeneralizedHoughGuil_(this.id, 'setTemplate', varargin{:});
        end
    end

    methods
        function value = get.CannyHighThresh(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'CannyHighThresh');
        end
        function set.CannyHighThresh(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'CannyHighThresh', value);
        end

        function value = get.CannyLowThresh(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'CannyLowThresh');
        end
        function set.CannyLowThresh(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'CannyLowThresh', value);
        end

        function value = get.Dp(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'Dp');
        end
        function set.Dp(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'Dp', value);
        end

        function value = get.MaxBufferSize(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'MaxBufferSize');
        end
        function set.MaxBufferSize(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'MaxBufferSize', value);
        end

        function value = get.MinDist(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'MinDist');
        end
        function set.MinDist(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'MinDist', value);
        end

        function value = get.AngleEpsilon(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'AngleEpsilon');
        end
        function set.AngleEpsilon(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'AngleEpsilon', value);
        end

        function value = get.AngleStep(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'AngleStep');
        end
        function set.AngleStep(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'AngleStep', value);
        end

        function value = get.AngleThresh(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'AngleThresh');
        end
        function set.AngleThresh(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'AngleThresh', value);
        end

        function value = get.Levels(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'Levels');
        end
        function set.Levels(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'Levels', value);
        end

        function value = get.MaxAngle(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'MaxAngle');
        end
        function set.MaxAngle(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'MaxAngle', value);
        end

        function value = get.MaxScale(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'MaxScale');
        end
        function set.MaxScale(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'MaxScale', value);
        end

        function value = get.MinAngle(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'MinAngle');
        end
        function set.MinAngle(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'MinAngle', value);
        end

        function value = get.MinScale(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'MinScale');
        end
        function set.MinScale(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'MinScale', value);
        end

        function value = get.PosThresh(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'PosThresh');
        end
        function set.PosThresh(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'PosThresh', value);
        end

        function value = get.ScaleStep(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'ScaleStep');
        end
        function set.ScaleStep(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'ScaleStep', value);
        end

        function value = get.ScaleThresh(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'ScaleThresh');
        end
        function set.ScaleThresh(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'ScaleThresh', value);
        end

        function value = get.Xi(this)
            value = GeneralizedHoughGuil_(this.id, 'get', 'Xi');
        end
        function set.Xi(this, value)
            GeneralizedHoughGuil_(this.id, 'set', 'Xi', value);
        end
    end

end
