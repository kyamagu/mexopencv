classdef Timelapser < handle
    %TIMELAPSER  Timelapser class
    %
    % Timelapser class, takes a sequence of images, applies appropriate shift,
    % stores result in `dst`.
    %
    % See also: cv.Stitcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = Timelapser(ttype)
            %TIMELAPSER  Constructor
            %
            %     obj = cv.Timelapser(ttype)
            %
            % ## Input
            % * __ttype__ Timelapsing method. One of:
            %   * __AsIs__ `Timelapser`.
            %   * __Crop__ `TimelapserCrop`.
            %
            % See also: cv.Timelapser.process
            %
            this.id = Timelapser_(0, 'new', ttype);
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Timelapser
            %
            if isempty(this.id), return; end
            Timelapser_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = Timelapser_(this.id, 'typeid');
        end
    end

    %% Timelapser
    methods
        function initialize(this, corners, sizes)
            %INITIALIZE  Initialize
            %
            %     obj.initialize(corners, sizes)
            %
            % ## Input
            % * __corners__ cell array of points `{[x,y], ...}`.
            % * __sizes__ cell array of sizes `{[w,h], ...}.
            %
            % See also: cv.Timelapser.process
            %
            Timelapser_(this.id, 'initialize', corners, sizes);
        end

        function process(this, img, mask, tl)
            %PROCESS  Process
            %
            %     obj.process(img, mask, tl)
            %
            % ## Input
            % * __img__ input image, of type `int16`.
            % * __mask__ mask (unused).
            % * __tl__ top-left corner point `[x,y]`.
            %
            % See also: cv.Timelapser.initialize
            %
            Timelapser_(this.id, 'process', img, mask, tl);
        end

        function dst = getDst(this)
            %GETDST  Get Destination
            %
            %     dst = obj.getDst()
            %
            % ## Output
            % * __dst__ output destination of type `int16`.
            %
            % See also: cv.Timelapser.process
            %
            dst = Timelapser_(this.id, 'getDst');
        end
    end

end
