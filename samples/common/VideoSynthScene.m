classdef VideoSynthScene < VideoSynthBase
    %VIDEOSYNTHSCENE  Scene synthetic video class
    %
    % ### Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.0/samples/python/video.py
    % * https://github.com/opencv/opencv/blob/3.3.0/samples/python/tst_scene_render.py
    %
    % See also: VideoSynthBase, createVideoCapture
    %

    properties (SetAccess = protected)
        time
        time_step
        speed
        deform
        fg
    end
    properties (Access = protected)
        radius       % [rx ry]
        center       % [x y]
        pts          % [x y; x y; x y; xy]
    end
    properties (Dependent, GetAccess = protected, SetAccess = private)
        offset       % [x,y]
    end

    methods
        function this = VideoSynthScene(varargin)
            %VIDEOSYNTHSCENE  Constructor
            %
            %     cap = VideoSynthScene('OptionName', optionValue, ...)
            %
            % ## Options
            % Accepts the same options as the open method.
            %
            % See also: VideoSynthScene.open
            %

            % explicitly call superclass constructor with specified arguments
            this = this@VideoSynthBase(varargin{:});
        end

        function release(this)
            %RELEASE  Clears allocated data
            %
            %     cap.release()
            %

            % call superclass RELEASE method
            release@VideoSynthBase(this);

            this.time = 0;
            this.time_step = 1;
            this.speed = 1;
            this.deform = true;
            this.fg = [];
            this.radius = [0 0];
            this.center = [0 0];
            this.pts = zeros(4,3);
        end

        function [retval, p] = open(this, varargin)
            %OPEN  Opens a synthetic video stream
            %
            %     retval = cap.open('OptionName',optionValue, ...)
            %
            % ## Output
            % * __retval__ bool, true if successful
            %
            % ## Options
            % Same as base class options, in addition to:
            % * __TimeStep__ time step, default 1/30
            % * __Speed__ speed, default 0.25
            % * __Deformation__ deform, default false
            % * __FG__ foreground image
            %
            % See also: VideoSynthBase.open
            %

            % call superclass OPEN method
            [retval, p] = open@VideoSynthBase(this, varargin{:});
            if ~retval, return; end

            % animation params
            this.time = 0;
            this.time_step = p.Results.TimeStep;
            this.speed = p.Results.Speed;
            this.deform = p.Results.Deformation;

            % foreground image
            if ~isempty(p.Results.FG)
                this.fg = p.Results.FG;
                fsz = [size(this.fg,2) size(this.fg,1)];
                this.center = fix((this.sz - fsz)/2);
                this.radius = this.sz - (this.center + fsz);
            else
                this.pts = fix(bsxfun(@plus, this.sz/2, ...
                    [0 0; this.w 0; this.w this.h; 0 this.h]/10));
                this.radius = this.sz * 7/20;  % [30 50]
            end
        end

        function offset = get.offset(this)
            t = this.time * this.speed;
            offset = fix(this.radius .* [cos(t) sin(t)]);
        end
    end

    methods (Access = protected)
        function p = optionsParser(this)
            %OPTIONSPARSER  Input arguments parser
            %
            %     p = cap.optionsParser()
            %
            % See also: VideoSynthBase.optionsParser
            %

            p = optionsParser@VideoSynthBase(this);
            p.addParameter('TimeStep', 1/30);
            p.addParameter('Speed', 0.25);
            p.addParameter('Deformation', false);
            p.addParameter('FG', []);
        end

        function [img, rect] = render(this, img)
            %RENDER  Renders additional layers as needed on top of background
            %
            %     img = cap.render(img)
            %
            % See also: VideoSynthBase.render
            %

            if ~isempty(this.fg)
                fsz = [size(this.fg,2) size(this.fg,1)];     % [h,w]
                c = this.center + this.offset;               % [x,y]
                rect = [c, fsz];                             % [x,y,w,h]
                if true
                    img(rect(2)+1:rect(2)+rect(4),rect(1)+1:rect(1)+rect(3),:) = this.fg;
                else
                    % slower
                    img = cv.Rect.crop(img, rect, this.fg);
                end
            else
                p = bsxfun(@plus, this.pts, this.offset);    % 4x2
                rect = cv.Rect.from2points(p(1,:), p(3,:));  % [x,y,w,h]
                if this.deform
                    p(2:3,:) = p(2:3,:) + this.h/20*cos(this.time);
                end
                img = cv.fillConvexPoly(img, p, 'Color',[0 0 255]);
            end
            this.time = this.time + this.time_step;
        end
    end
end
