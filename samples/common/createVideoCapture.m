function cap = createVideoCapture(source, fallback)
    %CREATEVIDEOCAPTURE  Create video capture object (real class or synthetic)
    %
    %     cap = createVideoCapture(devid)
    %     cap = createVideoCapture(filename)
    %     cap = createVideoCapture(synth)
    %     cap = createVideoCapture(..., fallback)
    %
    % ## Input
    % * __devid__ integer, id of the video capturing device to open.
    %   Passed to cv.VideoCapture class.
    % * __filename__ string, name of video file. Passed to cv.VideoCapture
    % * __synth__ procedural synthetic video. A string of the form
    %   'synth|key=value|key=value'. Supported parameters:
    %   * __class__ one of:
    %     * __base__ noisy BG image (default if no class specified)
    %     * __scene__ noisy BG image with a rotating FG image in front
    %     * __chess__ noisy BG image with a moving chess board in front
    %     * __aruco__ noisy BG image with a moving aruco board in front
    %   * __framecount__ maximum number of frames of video stream
    %   * __bg__ path to background image file name
    %   * __size__ string in the form WxH specifying width/height of frames
    %   * __noise__ amount of noise to add (number in the range [0,1])
    %   * __timestep__, __speed__, __deformation__, __fg__ see VideoSynthScene.open
    %   * __timestep__, __distcoeffs__, __gridsize__ see VideoSynthChess.open
    %   * __timestep__, __distcoeffs__, __fg__ see VideoSynthAruco.open
    % * __fallback__ fallback in case devid or filename fail to open capture.
    %   One of the following predefined presets:
    %   * __lena__ noisy lena image
    %   * __chess__ noisy lena image with a moving 10x7 chess board
    %   * __aruco__ noisy lena image with a moving ArUco board
    %   * __charuco__ noisy lena image with a moving ChArUco board
    %   * __book__ box image rotating in front of graffiti image
    %   * __cube__ cube moving in front of a background image
    %   * anything else, 640x480 white noise
    %
    % ### Example
    %
    %     cap = createVideoCapture('synth|class=chess|bg=../test/fruits.jpg|noise=0.3|size=320x240');
    %     img = cap.read();
    %     h = imshow(img);
    %     while ishghandle(h)
    %         img = cap.read();
    %         set(h, 'CData',img)
    %         drawnow
    %     end
    %
    % ### Example
    %
    %     % open first webcam, if fails fallback to fake lena video
    %     cap = createVideoCapture(0, 'lena');
    %     assert(cap.isOpened());
    %     cap.release();
    %
    % ### Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.0/samples/python/video.py
    %
    % See also: cv.VideoCapture, VideoSynthBase, VideoSynthScene,
    %  VideoSynthChess, VideoSynthAruco
    %

    narginchk(0,2);
    if nargin < 1, source = 0; end
    if nargin < 2, fallback = 'chess'; end
    if isempty(source)
        % presets
        cap = createVideoCapture(synth_presets(fallback));
    elseif isnumeric(source) || ~strncmpi(source, 'synth|', 6)
        % devid or a filename
        cap = cv.VideoCapture(source);
        if ~cap.isOpened()
            cap = createVideoCapture(synth_presets(fallback));
        end
    else
        % parse 'synth|key=value|key=value' string
        [params, klass] = parse_string(source);

        % create VideoSynth of the specified class
        switch klass
            case 'aruco'
                cap = VideoSynthAruco(params);
            case 'chess'
                cap = VideoSynthChess(params);
            case 'scene'
                cap = VideoSynthScene(params);
            otherwise
                cap = VideoSynthBase(params);
        end
    end
end

function [params, klass] = parse_string(source)
    % parse key/value pairs
    params = regexp(source(7:end), '\|', 'split');
    params = cellfun(@(s) regexp(s, '=', 'split', 'once'), params, 'UniformOutput',false);
    params = [params{:}];
    params(cellfun(@isempty, params)) = [];
    if mod(numel(params), 2) == 0
        params(1:2:end) = lower(params(1:2:end));
    end

    % convert to struct, and parse string values
    params = struct(params{:});
    params = structfun(@parse_value, params, 'UniformOutput',false);

    % get class param
    if isfield(params, 'class')
        klass = validatestring(params.class, {'base', 'scene', 'chess', 'aruco'});
        params = rmfield(params, 'class');
    else
        klass = 'base';
    end
end

function val = parse_value(str)
    str = strtrim(str);

    % string as-is (fallback case)
    val = str;
    if isempty(val)
        return;
    end

    % numeric
    tok = str2double(str);
    if ~isnan(tok)
        val = tok;
        return;
    end

    % size
    tok = regexp(str, '^(\d+)x(\d+)$', 'tokens', 'once', 'ignorecase');
    if ~isempty(tok)
        val = reshape(str2double(tok), 1, 2);
        return;
    end

    % logical
    tok = regexp(str, '^(true|false)$', 'tokens', 'once', 'ignorecase');
    if ~isempty(tok)
        val = strcmpi(tok, 'true');
        return;
    end

    % image file path
    if is_image_file(str) && file_exist(str)
        try
            val = cv.imread(resolve_path(str), 'Color',true);
        end
        return;
    end
end

function b = is_image_file(fpath)
    % check file extension is one of recognized image formats
    [~,~,ext] = fileparts(fpath);
    if isempty(ext)
        b = false;
    else
        fmts = imformats();
        fmts = strcat('.', [fmts.ext]);
        b = any(strcmpi(ext, fmts));
    end
end

function b = file_exist(fpath)
    if mexopencv.isOctave() || verLessThan('matlab', '9.3')  % R2017b
        b = exist(fpath, 'file') == 2;
    else
        b = isfile(fpath);
    end
end

function fpath = resolve_path(fpath)
    % convert relative to absolute path
    if false && strncmp(fpath, '.', 1)
        % base directory
        if true
            % current working directory
            dpath = pwd();
        else
            % directory of calling function
            st = dbstack();
            ind = find(strcmpi({st.file}, [mfilename('fullpath') '.m']), 1, 'last');
            assert(~isempty(ind) && ind < numel(st));
            dpath = fileparts(st(ind + 1).file);
        end
        fpath = fullfile(dpath, fpath);
    end

    % convert to canonical path
    if true
        fpath = which(fpath);
    elseif true
        s = what(fpath);
        fpath = s.path;
    elseif true
        s = fileattrib(fpath);
        fpath = s.Name;
    else
        obj = javaObject('java.io.File', fpath);
        fpath = char(obj.getCanonicalPath());
    end
end

function source = synth_presets(name)
    source = {'synth', 'noise=0.1'};
    %source{end+1} = 'framecount=300';
    %source{end+1} = 'size=320x320';
    switch lower(name)
        case 'lena'
            source{end+1} = ['bg=' mcv_which('lena.jpg')];
        case 'chess'
            source{end+1} = 'class=chess';
            source{end+1} = ['bg=' mcv_which('lena.jpg')];
        case 'aruco'
            source{end+1} = 'class=aruco';
            source{end+1} = ['bg=' mcv_which('lena.jpg')];
            source{end+1} = 'fg=ArUcoBoard';
        case 'charuco'
            source{end+1} = 'class=aruco';
            source{end+1} = ['bg=' mcv_which('lena.jpg')];
            source{end+1} = 'fg=ChArUcoBoard';
        case 'box'
            source{end+1} = 'class=aruco';
            source{end+1} = ['bg=' mcv_which('lena.jpg')];
            source{end+1} = ['fg=' mcv_which('box.png')];
        case 'book'
            source{end+1} = 'class=scene';
            source{end+1} = ['bg=' mcv_which('graf1.png')];
            source{end+1} = ['fg=' mcv_which('box.png')];
            source{end+1} = 'size=640x480';
            source{end+1} = 'speed=1';
        case 'cube'
            source{end+1} = 'class=scene';
            source{end+1} = ['bg=' mcv_which('fruits.jpg')];
            source{end+1} = 'speed=1';
            source{end+1} = 'deformation=true';
        otherwise
            source{end+1} = 'size=640x480';
    end
    source = strjoin(source, '|');
end

function p = mcv_which(fname)
    p = fullfile(mexopencv.root(), 'test', fname);
end
