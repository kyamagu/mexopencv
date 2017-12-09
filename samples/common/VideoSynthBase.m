classdef VideoSynthBase < handle
    %VIDEOSYNTHBASE  Base synthetic video class
    %
    % A stub/mock of the cv.VideoCapture class.
    %
    % ### Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.0/samples/python/video.py
    %
    % See also: cv.VideoCapture, createVideoCapture
    %

    properties (SetAccess = protected)
        iter     % frame counter
        max_iter % max number of frames
        bg       % background image (always RGB)
    end
    properties (Dependent, SetAccess = private)
        w        % frame width
        h        % frame height
        sz       % frame size [w,h]
    end
    properties
        noise    % noise level [0,1]
    end

    methods
        function this = VideoSynthBase(varargin)
            %VIDEOSYNTHBASE  Constructor
            %
            %     cap = VideoSynthBase('OptionName', optionValue, ...)
            %
            % ## Options
            % Accepts the same options as the open method.
            %
            % See also: VideoSynthBase.open
            %

            this.release();
            this.open(varargin{:});
        end

        function release(this)
            %RELEASE  Clears allocated data
            %
            %     cap.release()
            %

            this.iter = 0;
            this.max_iter = Inf;
            this.bg = [];
            this.noise = 0.0;
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
            % * __FrameCount__ max number of frames to produce, default Inf
            % * __BG__ background image, default 640x480 gray image
            % * __Size__ width/height of frames `[w,h]`, default [0,0]
            % * __Noise__ amount of noise to add (number in the range [0,1]),
            %   default 0
            %
            % See also: VideoSynthBase.optionsParser
            %

            % parse input params
            p = this.optionsParser();
            p.parse(varargin{:});
            this.max_iter = p.Results.FrameCount;
            this.bg = p.Results.BG;
            this.noise = p.Results.Noise;
            sz = p.Results.Size;

            % background image
            if isempty(this.bg)
                if all(sz==0), sz = [640 480]; end
                this.bg = 128 * ones([sz(2) sz(1) 3], 'uint8');
            elseif all(sz~=0)
                this.bg = cv.resize(this.bg, sz);
            end

            % success return value
            retval = true;
        end

        function retval = isOpened(this)
            %ISOPENED  Returns true if has been successfully initialized
            %
            %     retval = cap.isOpened()
            %
            % ## Output
            % * __retval__ true if object has been successfully initialized.
            %
            % See also: VideoSynthBase.open
            %

            retval = this.isvalid();
        end

        function img = read(this)
            %READ  Grabs and returns the next video frame
            %
            %     frame = cap.read()
            %
            % ## Output
            % * __frame__ output image
            %
            % See also: cv.VideoCapture.read
            %

            if this.iter >= this.max_iter
                img = uint8([]);
            else
                % increment counter
                this.iter = this.iter + 1;

                % start with the background image,
                % and render additional layers as needed on top
                img = this.render(this.bg);

                % add noise
                if this.noise > 0
                    img = this.addNoise(img);
                end
            end
        end

        function value = get(this, prop)
            %GET  Returns the specified property
            %
            %     value = cap.get(prop)
            %
            % ## Input
            % * __prop__ Property identifier.
            %
            % ## Output
            % * __value__ Value for the specified property.
            %
            % This method is partly implemented, to expose
            % cv.VideoCapture compatible API.
            %
            % See also: VideoSynthBase.set, cv.VideoCapture.get
            %

            switch upper(prop)
                case 'FRAMEWIDTH', value = this.w;
                case 'FRAMEHEIGHT', value = this.h;
                case 'FOURCC', value = 'FAKE';
                case 'POSFRAMES', value = this.iter;
                case 'FRAMECOUNT', value = this.max_iter;
                case 'POSAVIRATIO', value = this.iter / this.max_iter;
                otherwise
                    value = -1;  % 0
            end
        end

        function set(this, prop, value)
            %SET  Sets a property
            %
            %     cap.set(prop, value)
            %
            % ## Input
            % * __prop__ Property identifier.
            % * __value__ Value of the property.
            %
            % This method is partly implemented, to expose
            % cv.VideoCapture compatible API.
            %
            % See also: VideoSynthBase.get, cv.VideoCapture.set
            %

            switch upper(prop)
                case 'FRAMEWIDTH'
                    if ~isempty(this.bg)
                        this.bg = cv.resize(this.bg, [value this.h]);
                    end
                case 'FRAMEHEIGHT'
                    if ~isempty(this.bg)
                        this.bg = cv.resize(this.bg, [this.w value]);
                    end
                case 'POSFRAMES'
                    this.iter = value;
                case 'FRAMECOUNT'
                    this.max_iter = value;
            end
        end

        function w = get.w(this)
            w = size(this.bg,2);
        end

        function h = get.h(this)
            h = size(this.bg,1);
        end

        function sz = get.sz(this)
            sz = [size(this.bg,2) size(this.bg,1)];
        end
    end

    methods (Access = protected)
        function p = optionsParser(this)
            %OPTIONSPARSER  Input arguments parser
            %
            %     p = cap.optionsParser()
            %
            % ## Output
            % * __p__ input parser object
            %
            % See also: inputParser
            %

            p = inputParser();
            p.addParameter('FrameCount', Inf);
            p.addParameter('BG', []);
            p.addParameter('Size', [0 0]);
            p.addParameter('Noise', 0);
        end

        function img = render(this, img)
            %RENDER  Renders additional layers as needed on top of background
            %
            %     img = cap.render(img)
            %
            % ## Input
            % * __img__ input frame
            %
            % ## Output
            % * __img__ output frame
            %
            % See also: VideoSynthBase.read
            %

            % nothing here, method can be be overriden in subclasses
        end

        function img = addNoise(this, img)
            %ADDNOISE  Adds gaussian noise to image (mean=0, std=noise)
            %
            %     img = cap.addNoise(img)
            %
            % ## Input
            % * __img__ input frame
            %
            % ## Output
            % * __img__ output frame
            %
            % See also: imnoise
            %

            %HACK: try/catch faster than testing mexopencv.require('images')
            try
                img = imnoise(img, 'gaussian', 0, this.noise^2);
            catch
                img = my_imnoise(img, this.noise);
            end
        end
    end
end

function img = my_imnoise(img, noise_sd)
    %MY_IMNOISE  Adds noise to image
    %
    %     img = my_imnoise(img, noise)
    %
    % See also: imnoise
    %

    % handle integer vs double/single images
    clss = class(img);
    if isinteger(img)
        mxVal = double(intmax(clss));
        img = double(img) / mxVal;
        changedClass = true;
    else
        mxVal = 1.0;
        changedClass = false;
    end

    img = img + randn(size(img)) * noise_sd;
    img = max(min(img, 1), 0);    % clip to [0,1]

    if changedClass
        img = cast(round(img * mxVal), clss);
    end
end
