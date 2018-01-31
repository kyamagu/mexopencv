classdef EdgeBoxes < handle
    %EDGEBOXES  Class implementing Edge Boxes algorithm
    %
    % Algorithm from [ZitnickECCV14edgeBoxes].
    %
    % ## References
    % [ZitnickECCV14edgeBoxes]:
    % > C. Lawrence Zitnick and Piotr Dollar. "Edge boxes: Locating object
    % > proposals from edges". In ECCV, 2014.
    % > [PDF](https://www.microsoft.com/en-us/research/wp-content/uploads/2014/09/ZitnickDollarECCV14edgeBoxes.pdf)
    %
    % See also: cv.EdgeBoxes.EdgeBoxes, cv.StructuredEdgeDetection
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The step size of sliding window search.
        Alpha
        % The NMS threshold for object proposals.
        Beta
        % The adaptation rate for NMS threshold.
        Eta
        % The min score of boxes to detect.
        MinScore
        % The max number of boxes to detect.
        MaxBoxes
        % The edge min magnitude.
        EdgeMinMag
        % The edge merge threshold.
        EdgeMergeThr
        % The cluster min magnitude.
        ClusterMinMag
        % The max aspect ratio of boxes.
        MaxAspectRatio
        % The minimum area of boxes.
        MinBoxArea
        % The affinity sensitivity.
        Gamma
        % The scale sensitivity.
        Kappa
    end

    %% EdgeBoxes
    methods
        function this = EdgeBoxes(varargin)
            %EDGEBOXES  Creates instance of Edgeboxes
            %
            %     obj = cv.EdgeBoxes()
            %     obj = cv.EdgeBoxes('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Alpha__ step size of sliding window search. default 0.65
            % * __Beta__ NMS threshold for object proposals. default 0.75
            % * __Eta__ adaptation rate for NMS threshold. default 1
            % * __MinScore__ min score of boxes to detect. default 0.01
            % * __MaxBoxes__ max number of boxes to detect. default 10000
            % * __EdgeMinMag__ edge min magnitude. Increase to trade off
            %   accuracy for speed. default 0.1
            % * __EdgeMergeThr__ edge merge threshold. Increase to trade off
            %   accuracy for speed. default 0.5
            % * __ClusterMinMag__ cluster min magnitude. Increase to trade off
            %   accuracy for speed. default 0.5
            % * __MaxAspectRatio__ max aspect ratio of boxes. default 3
            % * __MinBoxArea__ minimum area of boxes. default 1000
            % * __Gamma__ affinity sensitivity. default 2
            % * __Kappa__ scale sensitivity. default 1.5
            %
            % See also: cv.EdgeBoxes.getBoundingBoxes
            %
            this.id = EdgeBoxes_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.EdgeBoxes
            %
            if isempty(this.id), return; end
            EdgeBoxes_(this.id, 'delete');
        end

        function boxes = getBoundingBoxes(this, edgeMap, orientationMap)
            %GETBOUNDINGBOXES  Returns array containing proposal boxes.
            %
            %     boxes = obj.getBoundingBoxes(edgeMap, orientationMap)
            %
            % ## Input
            % * __edgeMap__ edge image.
            % * __orientationMap__ orientation map.
            %
            % ## Output
            % * __boxes__ proposal boxes.
            %
            % See also: cv.EdgeBoxes.amFilter
            %
            boxes = EdgeBoxes_(this.id, 'getBoundingBoxes', edgeMap, orientationMap);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.EdgeBoxes.empty, cv.EdgeBoxes.load
            %
            EdgeBoxes_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if algorithm object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm object is empty
            %   (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.EdgeBoxes.clear, cv.EdgeBoxes.load
            %
            b = EdgeBoxes_(this.id, 'empty');
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
            % See also: cv.EdgeBoxes.load
            %
            EdgeBoxes_(this.id, 'save', filename);
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
            % See also: cv.EdgeBoxes.save
            %
            EdgeBoxes_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.EdgeBoxes.save, cv.EdgeBoxes.load
            %
            name = EdgeBoxes_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.Alpha(this)
            value = EdgeBoxes_(this.id, 'get', 'Alpha');
        end
        function set.Alpha(this, value)
            EdgeBoxes_(this.id, 'set', 'Alpha', value);
        end

        function value = get.Beta(this)
            value = EdgeBoxes_(this.id, 'get', 'Beta');
        end
        function set.Beta(this, value)
            EdgeBoxes_(this.id, 'set', 'Beta', value);
        end

        function value = get.Eta(this)
            value = EdgeBoxes_(this.id, 'get', 'Eta');
        end
        function set.Eta(this, value)
            EdgeBoxes_(this.id, 'set', 'Eta', value);
        end

        function value = get.MinScore(this)
            value = EdgeBoxes_(this.id, 'get', 'MinScore');
        end
        function set.MinScore(this, value)
            EdgeBoxes_(this.id, 'set', 'MinScore', value);
        end

        function value = get.MaxBoxes(this)
            value = EdgeBoxes_(this.id, 'get', 'MaxBoxes');
        end
        function set.MaxBoxes(this, value)
            EdgeBoxes_(this.id, 'set', 'MaxBoxes', value);
        end

        function value = get.EdgeMinMag(this)
            value = EdgeBoxes_(this.id, 'get', 'EdgeMinMag');
        end
        function set.EdgeMinMag(this, value)
            EdgeBoxes_(this.id, 'set', 'EdgeMinMag', value);
        end

        function value = get.EdgeMergeThr(this)
            value = EdgeBoxes_(this.id, 'get', 'EdgeMergeThr');
        end
        function set.EdgeMergeThr(this, value)
            EdgeBoxes_(this.id, 'set', 'EdgeMergeThr', value);
        end

        function value = get.ClusterMinMag(this)
            value = EdgeBoxes_(this.id, 'get', 'ClusterMinMag');
        end
        function set.ClusterMinMag(this, value)
            EdgeBoxes_(this.id, 'set', 'ClusterMinMag', value);
        end

        function value = get.MaxAspectRatio(this)
            value = EdgeBoxes_(this.id, 'get', 'MaxAspectRatio');
        end
        function set.MaxAspectRatio(this, value)
            EdgeBoxes_(this.id, 'set', 'MaxAspectRatio', value);
        end

        function value = get.MinBoxArea(this)
            value = EdgeBoxes_(this.id, 'get', 'MinBoxArea');
        end
        function set.MinBoxArea(this, value)
            EdgeBoxes_(this.id, 'set', 'MinBoxArea', value);
        end

        function value = get.Gamma(this)
            value = EdgeBoxes_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            EdgeBoxes_(this.id, 'set', 'Gamma', value);
        end

        function value = get.Kappa(this)
            value = EdgeBoxes_(this.id, 'get', 'Kappa');
        end
        function set.Kappa(this, value)
            EdgeBoxes_(this.id, 'set', 'Kappa', value);
        end
    end

end
