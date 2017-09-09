classdef HausdorffDistanceExtractor < handle
    %HAUSDORFFDISTANCEEXTRACTOR  A simple Hausdorff distance measure between shapes defined by contours
    %
    % According to the paper [Hausdorff93].
    %
    % ## References
    % [Hausdorff93]:
    % > "Comparing Images using the Hausdorff distance." by
    % > D.P. Huttenlocher, G.A. Klanderman, and W.J. Rucklidge. (PAMI 1993)
    %
    % See also: cv.HausdorffDistanceExtractor.HausdorffDistanceExtractor,
    %  cv.ShapeContextDistanceExtractor, cv.matchShapes
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The norm used to compute the Hausdorff distance between two shapes.
        %
        % It can be 'L1' or 'L2' norm. default 'L2'
        DistanceFlag
        % The rank proportion (a fractional value between 0 and 1) that
        % establish the K-th ranked value of the partial Hausdorff distance.
        %
        % Experimentally had been shown that 0.6 is a good value to compare
        % shapes. default 0.6
        RankProportion
    end

    %% HausdorffDistanceExtractor
    methods
        function this = HausdorffDistanceExtractor(varargin)
            %HAUSDORFFDISTANCEEXTRACTOR  Constructor
            %
            %     obj = cv.HausdorffDistanceExtractor()
            %     obj = cv.HausdorffDistanceExtractor('OptionName',optionValue, ...)
            %
            % ## Options
            % * __DistanceFlag__ see
            %   cv.HausdorffDistanceExtractor.DistanceFlag, default 'L2'
            % * __RankProportion__ see
            %   cv.HausdorffDistanceExtractor.RankProportion, default 0.6
            %
            % See also: cv.HausdorffDistanceExtractor.computeDistance
            %
            this.id = HausdorffDistanceExtractor_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.HausdorffDistanceExtractor
            %
            if isempty(this.id), return; end
            HausdorffDistanceExtractor_(this.id, 'delete');
        end
    end

    %% ShapeDistanceExtractor
    methods
        function dist = computeDistance(this, contour1, contour2)
            %COMPUTEDISTANCE  Compute the shape distance between two shapes defined by its contours
            %
            %     dist = obj.computeDistance(contour1, contour2)
            %
            % ## Options
            % * __contour1__ Contour defining first shape. A numeric
            %   Nx2/Nx1x2/1xNx2 array or a cell-array of 2D points
            %   `{[x,y], ...}`
            % * __contour2__ Contour defining second shape. Same format as
            %   `contours1`.
            %
            % ## Output
            % * __dist__ output distance.
            %
            % See also: cv.HausdorffDistanceExtractor.HausdorffDistanceExtractor
            %
            dist = HausdorffDistanceExtractor_(this.id, 'computeDistance', contour1, contour2);
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.HausdorffDistanceExtractor.empty,
            %  cv.HausdorffDistanceExtractor.load
            %
            HausdorffDistanceExtractor_(this.id, 'clear');
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
            % See also: cv.HausdorffDistanceExtractor.clear,
            %  cv.HausdorffDistanceExtractor.load
            %
            b = HausdorffDistanceExtractor_(this.id, 'empty');
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
            % See also: cv.HausdorffDistanceExtractor.load
            %
            HausdorffDistanceExtractor_(this.id, 'save', filename);
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
            % See also: cv.HausdorffDistanceExtractor.save
            %
            HausdorffDistanceExtractor_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.HausdorffDistanceExtractor.save,
            %  cv.HausdorffDistanceExtractor.load
            %
            name = HausdorffDistanceExtractor_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.DistanceFlag(this)
            value = HausdorffDistanceExtractor_(this.id, 'get', 'DistanceFlag');
        end
        function set.DistanceFlag(this, value)
            HausdorffDistanceExtractor_(this.id, 'set', 'DistanceFlag', value);
        end

        function value = get.RankProportion(this)
            value = HausdorffDistanceExtractor_(this.id, 'get', 'RankProportion');
        end
        function set.RankProportion(this, value)
            HausdorffDistanceExtractor_(this.id, 'set', 'RankProportion', value);
        end
    end

end
