classdef VideoSynthAruco < VideoSynthBase
    %VIDEOSYNTHARUCO  Aruco synthetic video class
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
        fg          % foreground image (aruco imag)
    end

    methods
        function this = VideoSynthAruco(varargin)
            %VIDEOSYNTHARUCO  Constructor
            %
            %     cap = VideoSynthAruco('OptionName', optionValue, ...)
            %
            % ## Options
            % Accepts the same options as the open method.
            %
            % See also: VideoSynthAruco.open
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
            this.fg = [];
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
            % * __FG__ aruco board image, or one of the following presets:
            %   * __ArUcoMarker__ see cv.drawMarkerAruco
            %   * __ChArUcoDiamond__ see cv.drawCharucoDiamond
            %   * __ArUcoBoard__ see cv.drawPlanarBoard
            %   * __ChArUcoBoard__ see cv.drawCharucoBoard
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

            % aruco image
            if ischar(p.Results.FG)
                % one of presets
                this.fg = create_aruco_image(p.Results.FG);
            else
                % any image really
                this.fg = p.Results.FG;
            end
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
            p.addParameter('FG', 'ArucoBoard');
        end

        function img = render(this, img)
            %RENDER  Renders additional layers as needed on top of background
            %
            %     img = cap.render(img)
            %
            % See also: VideoSynthBase.render
            %

            fsz = [size(this.fg,2) size(this.fg,1)];

            % get current pose (rotation/translation vectors)
            [rvec, tvec] = getSyntheticRT(this.time, fsz);
            this.time = this.time + this.time_step;

            % aruco image corners
            p3 = [0 0; fsz(1) 0; fsz(1) fsz(2); 0 fsz(2)];
            p3(:,3) = 0;  % Z=0

            % project corners from 3D to 2D
            p2 = cv.projectPoints(p3, rvec, tvec, ...
                this.cam_mat, 'DistCoeffs',this.dist_coeff);

            % compute perspective transform (between 4 matching points)
            if true
                T = cv.getPerspectiveTransform(p3(:,1:2), p2);
            else
                T = cv.findHomography(p3(:,1:2), p2);
            end

            % apply transform to aruco image projected on top of background image
            img = cv.warpPerspective(flip(this.fg, 2), T, ...
                'Dst',img, 'DSize',this.sz, 'BorderType','Transparent');
        end
    end
end

%% Helper functions

function img = create_aruco_image(config)
    % draw aruco/charuco marker or board from one of predefined configurations
    config = validatestring(config, ...
        {'ArUcoMarker', 'ChArUcoDiamond', 'ArUcoBoard', 'ChArUcoBoard'});
    dict = {'Predefined', '6x6_250'};
    switch config
        case 'ArUcoMarker'
            id = randi(250) - 1;
            img = cv.drawMarkerAruco(dict, id, 200);
            img = cv.copyMakeBorder(img, [25 25 25 25], ...
                'BorderType','Constant', 'Value',255);
        case 'ChArUcoDiamond'
            ids = randi(250, [1 4]) - 1;
            img = cv.drawCharucoDiamond(dict, ids, 120, 60, 'MarginSize',30);
        case 'ArUcoBoard'
            board = {'GridBoard', 5, 7, 60, 15, dict};
            sz = [board{2:3}] * sum([board{4:5}]) - board{5} + 2 * board{5};
            img = cv.drawPlanarBoard(board, sz, 'MarginSize',board{5});
        case 'ChArUcoBoard'
            board = {5, 7, 60, 30, dict};
            margins = board{3} - board{4};
            sz = [board{1:2}] * board{3} + 2 * margins;
            img = cv.drawCharucoBoard(board, sz, 'MarginSize',margins);
    end
    img = cv.cvtColor(img, 'GRAY2RGB');
end

function [rvec, tvec] = getSyntheticRT(t, sz)
    % compute eye/target positions for transformed image
    center = [0.5*sz(:); 0];
    phi = pi/3 + sin(t*3)*pi/8;
    ofs = [sin(1.2*t); cos(1.8*t); 0] * sz(1) * 0.2;
    eye_pos = center + [cos(t)*cos(phi); sin(t)*cos(phi); sin(phi)] * 15*60 + ofs;
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
