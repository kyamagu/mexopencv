classdef VideoSynthChess < VideoSynthBase
    %VIDEOSYNTHCHESS  Chess synthetic video class
    %
    % ### Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.0/samples/python/video.py
    %
    % See also: VideoSynthBase, createVideoCapture
    %

    properties (SetAccess = protected)
        time        % current time
        time_step   % time step
        cam_mat     % camera matrix (intrinsic parameters)
        dist_coeff  % lens distortion coefficients
        grid_size   % checkerboard grid size
    end
    properties (Access = protected)
        quads_w     % white quads of grid
        quads_b     % black quads of grid
    end

    methods
        function this = VideoSynthChess(varargin)
            %VIDEOSYNTHCHESS  Constructor
            %
            %     cap = VideoSynthChess('OptionName', optionValue, ...)
            %
            % ## Options
            % Accepts the same options as the open method.
            %
            % See also: VideoSynthChess.open
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
            this.cam_mat = eye(3,3);
            this.dist_coeff = zeros(1,4);
            this.grid_size = [0 0];
            this.quads_w = {};
            this.quads_b = {};
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
            % * __DistCoeffs__ radial distortion coefficients,
            %   default [-0.2 0.1 0 0]
            % * __GridSize__ grid size, default [10 7]
            %
            % See also: VideoSynthBase.open
            %

            % call superclass OPEN method
            [retval, p] = open@VideoSynthBase(this, varargin{:});
            if ~retval, return; end

            % time variable
            this.time = 0;
            this.time_step = p.Results.TimeStep;

            % intrinsic camera parameters
            fx = 0.9;   % focal lengths expressed in pixel-related units
            this.cam_mat = [
                fx*this.w     0     (this.w-1)/2 ;
                    0     fx*this.h (this.h-1)/2 ;
                    0         0           1
            ];
            this.dist_coeff = p.Results.DistCoeffs;

            % grid quads
            this.grid_size = p.Results.GridSize;
            [this.quads_w, this.quads_b] = create_grid_quads(this.grid_size);
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
            p.addParameter('DistCoeffs', [-0.2 0.1 0 0]);
            p.addParameter('GridSize', [10 7]);
        end

        function img = render(this, img)
            %RENDER  Renders additional layers as needed on top of background
            %
            %     img = cap.render(img)
            %
            % See also: VideoSynthBase.render
            %

            % get current pose (rotation/translation vectors)
            [rvec, tvec] = getSyntheticRT(this.time, this.grid_size);
            this.time = this.time + this.time_step;

            % draw checkerboard quads on top of image
            img = draw_quads(img, this.quads_w, rvec, tvec, ...
                this.cam_mat, this.dist_coeff, [255 255 255]-10);
            img = draw_quads(img, this.quads_b, rvec, tvec, ...
                this.cam_mat, this.dist_coeff, [0 0 0]+10);
        end
    end
end

%% Helper functions

function [white_quads, black_quads] = create_grid_quads(sz)
    % build grid base-points (with Z=0)
    [X,Y,Z] = meshgrid(0:sz(2)-1, 0:sz(1)-1, 0);
    XYZ = [Y(:) X(:) Z(:)];

    % assignment of quads to white/black <-> 1/2
    wbIdx = mod(sum(XYZ, 2), 2) + 1;

    % generate the quad points from base points
    inc = [0 0 0; 1 0 0; 1 1 0; 0 1 0]; % BL, BR, TR, TL
    XYZ = cellfun(@(c) bsxfun(@plus, c, inc), ...
        num2cell(XYZ,2), 'UniformOutput',false);

    % split them into alternating white/black
    white_quads = XYZ(wbIdx == 1);
    black_quads = XYZ(wbIdx == 2);
end

function [rvec, tvec] = getSyntheticRT(t, sz)
    % compute eye/target positions for transformed checkerboard
    center = [0.5*sz(:); 0];
    phi = pi/3 + sin(t*3)*pi/8;
    ofs = [sin(1.2*t); cos(1.8*t); 0] * sz(1) * 0.2;
    eye_pos = center + [cos(t)*cos(phi); sin(t)*cos(phi); sin(phi)] * 15 + ofs;
    target_pos = center + ofs;

    % compute rotation matrix, translation vector (extrinsic parameters)
    [R, tvec] = lookat(eye_pos, target_pos);
    rvec = mtx2rvec(R);
end

function [R, tvec] = lookat(eyePos, targetPos, up)
    if nargin < 3, up = [0; 0; 1]; end
    fwd = (targetPos - eyePos);
    fwd = fwd / norm(fwd);
    right = cross(fwd, up);
    right = right / norm(right);
    down = cross(fwd, right);
    R = [right(:), down(:), fwd(:)]';
    tvec = -R * eyePos(:);
end

function rvec = mtx2rvec(R)
    % rotation vector (compact representation of a rotation matrix)
    if true
        rvec = cv.Rodrigues(R);
    else
        [U,S,V] = svd(R - eye(3));
        p = V(:,1) + U(:,1)*S(1,1);
        c = dot(V(:,1), p);
        s = dot(V(:,2), p);
        ax = cross(V(:,1), V(:,2));
        rvec = ax * atan2(s, c);
    end
end

function img = draw_quads(img, quads, rvec, tvec, cam_mat, dist_coeff, clr)
    %DRAW_QUADS  Render quads on top of image with specified color
    %
    %     img = draw_quads(img, quads, rvec, tvec, cam_mat, dist_coeff, clr)
    %
    % ## Input
    % * __img__ input frame
    % * __quads__ cell array of quad corners `{[x y z; ..], ..}`,
    %   four corners per quad
    % * __rvec__ rotation vector
    % * __tvec__ translation vector
    % * **cam_mat** camera matrix
    % * **dist_coeff** distortion coefficients
    % * __clr__ color
    %
    % ## Output
    % * __img__ output frame
    %

    if nargin < 7, clr = [128 128 128]; end

    % project all points (concatenated) from 3D to 2D
    img_quads = cv.projectPoints(cat(1, quads{:}), rvec, tvec, ...
        cam_mat, 'DistCoeffs',dist_coeff);

    % draw quads
    num = size(img_quads,1) / 4;
    if true
        % separate back each 4 points in a cell
        q = mat2cell(img_quads, repmat(4,1,num), 2);
        img = cv.fillPoly(img, q, 'Color',clr, 'LineType','AA');
    else
        % slower
        for i=1:num
            img = cv.fillConvexPoly(img, img_quads(i,:)*4, ...
                'Color',clr, 'LineType','AA', 'Shift',2);
        end
    end
end
