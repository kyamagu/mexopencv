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
        % Canny high threshold.
        CannyHighThresh
        % Canny low threshold.
        CannyLowThresh
        % Inverse ratio of the accumulator resolution to the image resolution.
        Dp
        % Maximal size of inner buffers.
        MaxBufferSize
        % Minimum distance between the centers of the detected objects.
        MinDist

        % Maximal difference between angles that treated as equal.
        AngleEpsilon
        % Angle step in degrees.
        AngleStep
        % Angle votes threshold.
        AngleThresh
        % Feature table levels.
        Levels
        % Maximal rotation angle to detect in degrees.
        MaxAngle
        % Maximal scale to detect.
        MaxScale
        % Minimal rotation angle to detect in degrees.
        MinAngle
        % Minimal scale to detect.
        MinScale
        % Position votes threshold.
        PosThresh
        % Scale step.
        ScaleStep
        % Scale votes threshold.
        ScaleThresh
        % Angle difference in degrees between two points in feature.
        Xi
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
            % * __image__
            % * __edges__
            % * __dx__
            % * __dy__
            %
            % ## Output
            % * __positions__
            % * __votes__
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
            % * __templ__
            % * __edges__
            % * __dx__
            % * __dy__
            %
            % ## Options
            % * __Center__
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
