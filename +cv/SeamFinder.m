classdef SeamFinder < handle
    %SEAMFINDER  Class for all seam estimators
    %
    % See also: cv.Stitcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = SeamFinder(seamType, varargin)
            %SEAMFINDER  Constructor
            %
            %     obj = cv.SeamFinder(seamType)
            %     obj = cv.SeamFinder(seamType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __seamType__ seam estimator type. One of:
            %   * __NoSeamFinder__ Stub seam estimator which does nothing.
            %   * __VoronoiSeamFinder__ Voronoi diagram-based pairwise seam
            %     estimator.
            %   * __DpSeamFinder__
            %   * __GraphCutSeamFinder__ Minimum graph cut-based seam
            %     estimator. See details in [V03].
            %   * __GraphCutSeamFinderGpu__ (requires CUDA)
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `DpSeamFinder`
            % * __CostFunction__ default 'Color'. One of:
            %   * __Color__
            %   * __ColorGrad__
            %
            % ### `GraphCutSeamFinder`
            % * __CostType__ default 'ColorGrad'. One of:
            %   * __Color__
            %   * __ColorGrad__
            % * __TerminalCost__ default 10000.0
            % * __BadRegionPenaly__ default 1000.0
            %
            % ## References
            % [V03]:
            % > Vivek Kwatra, Arno Schodl, Irfan Essa, Greg Turk, and Aaron
            % > Bobick. "Graphcut textures: image and video synthesis using
            % > graph cuts". In ACM Transactions on Graphics (ToG), volume 22,
            % > pages 277-286. ACM, 2003.
            %
            % See also: cv.SeamFinder.find
            %
            this.id = SeamFinder_(0, 'new', seamType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SeamFinder
            %
            if isempty(this.id), return; end
            SeamFinder_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = SeamFinder_(this.id, 'typeid');
        end
    end

    %% SeamFinder
    methods
        function masks = find(this, src, corners, masks)
            %FIND  Estimates seams
            %
            %     masks = obj.find(src, corners, masks)
            %
            % ## Input
            % * __src__ Source cell-array of images.
            % * __corners__ Source image top-left corners, cell-array of 2D
            %   points `{[x,y], ...}`.
            % * __masks__ Source cell-array of image masks to update.
            %
            % ## Output
            % * __masks__ resolved masks intersection.
            %
            masks = SeamFinder_(this.id, 'find', src, corners, masks);
        end
    end

end
