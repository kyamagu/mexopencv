classdef VideoCapture < handle
    %VIDEOCAPTURE  Class for video capturing from video files or cameras
    %
    % The class provides an API for capturing video from cameras or for
    % reading video files and image sequences.
    %
    % When querying a property that is not supported by the backend used by
    % the cv.VideoCapture class, value 0 is returned.
    %
    % ## Example
    % Here is how the class can be used:
    %
    %    cap = cv.VideoCapture(0);        % open the default camera
    %    pause(3);                        % see note below
    %    if ~cap.isOpened()               % check if we succeeded
    %        error('camera failed to initialized');
    %    end
    %    for t=1:30
    %       frame = cap.read();           % get a new frame from camera
    %       imshow(frame);
    %       pause(0.1);
    %    end
    %    % the camera will be deinitialized automatically in destructor
    %    % when "cap" goes out of scope
    %
    % ## Note
    % In some environments, there is a concurrency issue during camera
    % initialization. To avoid unexpected crash, pause for a few seconds after
    % the initialization of cv.VideoCapture object.
    %
    % See also: cv.VideoCapture.VideoCapture, cv.VideoCapture.read
    %   VideoReader, mmreader, aviread, webcam, videoinput, imaq.VideoDevice,
    %   vision.VideoFileReader
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Current position of the video file in milliseconds or video capture
        % timestamp.
        PosMsec
        % 0-based index of the frame to be decoded/captured next.
        PosFrames
        % Relative position of the video file:
        % 0 - start of the film, 1 - end of the film.
        PosAviRatio
        % Width of the frames in the video stream.
        FrameWidth
        % Height of the frames in the video stream.
        FrameHeight
        % Frame rate.
        FPS
        % 4-character code of codec.
        FourCC
        % Number of frames in the video file.
        FrameCount
        % Format of the frames returned by cv.VideoCapture.retrieve.
        Format
        % Backend-specific value indicating the current capture mode.
        Mode
        % Brightness of the image (only for cameras).
        Brightness
        % Contrast of the image (only for cameras).
        Contrast
        % Saturation of the image (only for cameras).
        Saturation
        % Hue of the image (only for cameras).
        Hue
        % Gain of the image (only for cameras).
        Gain
        % Exposure (only for cameras).
        Exposure
        % Boolean flags indicating whether images should be converted to RGB.
        ConvertRGB
        % Currently unsupported
        %WhiteBalance
        % Rectification flag for stereo cameras
        % (note: only supported by DC1394 v2.x backend currently)
        Rectification
    end

    methods
        function this = VideoCapture(filename)
            %VIDEOCAPTURE  Create a new VideoCapture object
            %
            %    cap = cv.VideoCapture(devid)
            %    cap = cv.VideoCapture(filename)
            %
            % ## Input
            % * __devid__ id of the opened video capturing device (i.e. a
            %       camera index). If there is a single camera connected, just
            %       pass 0.
            % * __filename__ name of the opened video file (eg. `video.avi`)
            %       or image sequence (eg. `img_%02d.jpg`, which will read
            %       samples like `img_00.jpg`, `img_01.jpg`, `img_02.jpg`, ...)
            %
            % Creates a new video capture instance. With no argument, it
            % connects to the default camera device found in the system.
            % You can specify camera devices by `devid`, an integer value
            % starting from 0. You can also specify a `filename` to open a
            % video file.
            %
            % See also: cv.VideoCapture.open
            %
            if nargin < 1, filename = 0; end
            this.id = VideoCapture_(0, 'new', filename);
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.VideoCapture.release
            %
            VideoCapture_(this.id, 'delete');
        end

        function successFlag = open(this, filename)
            %OPEN  Open video file or a capturing device for video capturing
            %
            %    successFlag = cap.open(devid)
            %    successFlag = cap.open(filename)
            %
            % ## Input
            % Inputs are the same as in the constructor.
            %
            % ## Output
            % * __successFlag__ bool, true if successful
            %
            % The method first call cv.VideoCapture.release to close the
            % already opened file or camera.
            %
            % See also: cv.VideoCapture.VideoCapture, cv.VideoCapture.isOpened
            %
            if nargin < 1, filename = 0; end
            successFlag = VideoCapture_(this.id, 'open', filename);
        end

        function retval = isOpened(this)
            %ISOPENED  Returns true if video capturing has been initialized already
            %
            %    retval = cap.isOpened()
            %
            % ## Output
            % * __retval__ bool, return value
            %
            % If the previous call to constructor or cv.VideoCapture.open
            % succeeded, the method returns true.
            %
            % See also: cv.VideoCapture.open
            %
            retval = VideoCapture_(this.id, 'isOpened');
        end

        function release(this)
            %RELEASE  Closes video file or capturing device
            %
            %    cap.release()
            %
            % The method is automatically called by subsequent
            % cv.VideoCapture.open and by destructor.
            %
            % See also: cv.VideoCapture.open
            %
            VideoCapture_(this.id, 'release');
        end

        function frame = read(this, varargin)
            %READ  Grabs, decodes and returns the next video frame
            %
            %    frame = cap.read()
            %    frame = cap.read('OptionName',optionValue, ...)
            %
            % ## Output
            % * __frame__ output image
            %
            % ## Options
            % * __FlipChannels__ in case the output is color image, flips the
            %       color order from OpenCV's BGR to MATLAB's RGB order.
            %       default true
            %
            % The method combines cv.VideoCapture.grab and
            % cv.VideoCapture.retrieve in one call. This is the most
            % convenient method for reading video files or capturing data from
            % decode and return the just grabbed frame. If no frames has been
            % grabbed (camera has been disconnected, or there are no more
            % frames in video file), the function return an empty matrix.
            %
            % See also: cv.VideoCapture.grab, cv.VideoCapture.retrieve
            %
            frame = VideoCapture_(this.id, 'read', varargin{:});
        end

        function successFlag = grab(this)
            %GRAB  Grabs the next frame from video file or capturing device
            %
            %    successFlag = cap.grab()
            %
            % ## Output
            % * __successFlag__ bool, success flag
            %
            % The function grabs the next frame from video file or camera and
            % returns true (non-zero) in the case of success.
            %
            % The primary use of the function is in multi-camera environments,
            % especially when the cameras do not have hardware synchronization.
            % That is, you call cv.VideoCapture.grab for each camera and after
            % that call the slower method cv.VideoCapture.retrieve to decode
            % and get frame from each camera. This way the overhead on
            % demosaicing or motion jpeg decompression etc. is eliminated and
            % the retrieved frames from different cameras will be closer in
            % time.
            %
            % Also, when a connected camera is multi-head (for example, a
            % stereo camera or a Kinect device), the correct way of retrieving
            % data from it is to call cv.VideoCapture.grab first and then call
            % cv.VideoCapture.retrieve one or more times with different values
            % of the channel parameter `StreamIdx`.
            %
            % See also: cv.VideoCapture.read, cv.VideoCapture.retrieve
            %
            successFlag = VideoCapture_(this.id, 'grab');
        end

        function frame = retrieve(this, varargin)
            %RETRIEVE  Decodes and returns the grabbed video frame
            %
            %    frame = cap.retrieve()
            %    frame = cap.retrieve('OptionName',optionValue, ...)
            %
            % ## Output
            % * __frame__ output image
            %
            % ## Options
            % * __StreamIdx__ 0-based index (for multi-head camera). default 0
            % * __FlipChannels__ in case the output is color image, flips the
            %       color order from OpenCV's BGR to MATLAB's RGB order.
            %       default true
            %
            % The function decodes and returns the just grabbed frame. If no
            % frames has been grabbed (camera has been disconnected, or there
            % are no more frames in video file), the function returns an empty
            % matrix.
            %
            % See also: cv.VideoCapture.read, cv.VideoCapture.grab
            %
            frame = VideoCapture_(this.id, 'retrieve', varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.PosMsec(this)
            value = VideoCapture_(this.id, 'get', 'PosMsec');
        end
        function set.PosMsec(this, value)
            VideoCapture_(this.id, 'set', 'PosMsec', value);
        end

        function value = get.PosFrames(this)
            value = VideoCapture_(this.id, 'get', 'PosFrames');
        end
        function set.PosFrames(this, value)
            VideoCapture_(this.id, 'set', 'PosFrames', value);
        end

        function value = get.PosAviRatio(this)
            value = VideoCapture_(this.id, 'get', 'PosAviRatio');
        end
        function set.PosAviRatio(this, value)
            VideoCapture_(this.id, 'set', 'PosAviRatio', value);
        end

        function value = get.FrameWidth(this)
            value = VideoCapture_(this.id, 'get', 'FrameWidth');
        end
        function set.FrameWidth(this, value)
            VideoCapture_(this.id, 'set', 'FrameWidth', value);
        end

        function value = get.FrameHeight(this)
            value = VideoCapture_(this.id, 'get', 'FrameHeight');
        end
        function set.FrameHeight(this, value)
            VideoCapture_(this.id, 'set', 'FrameHeight', value);
        end

        function value = get.FPS(this)
            value = VideoCapture_(this.id, 'get', 'FPS');
        end
        function set.FPS(this, value)
            VideoCapture_(this.id, 'set', 'FPS', value);
        end

        function value = get.FourCC(this)
            value = int32(VideoCapture_(this.id, 'get', 'FourCC'));
            %value = char(typecast(value, 'uint8'));  %TODO
        end
        function set.FourCC(this, value)
            VideoCapture_(this.id, 'set', 'FourCC', value);
        end

        function value = get.FrameCount(this)
            value = VideoCapture_(this.id, 'get', 'FrameCount');
        end
        function set.FrameCount(this, value)
            VideoCapture_(this.id, 'set', 'FrameCount', value);
        end

        function value = get.Format(this)
            value = VideoCapture_(this.id, 'get', 'Format');
        end
        function set.Format(this, value)
            VideoCapture_(this.id, 'set', 'Format', value);
        end

        function value = get.Mode(this)
            value = VideoCapture_(this.id, 'get', 'Mode');
        end
        function set.Mode(this, value)
            VideoCapture_(this.id, 'set', 'Mode', value);
        end

        function value = get.Brightness(this)
            value = VideoCapture_(this.id, 'get', 'Brightness');
        end
        function set.Brightness(this, value)
            VideoCapture_(this.id, 'set', 'Brightness', value);
        end

        function value = get.Contrast(this)
            value = VideoCapture_(this.id, 'get', 'Contrast');
        end
        function set.Contrast(this, value)
            VideoCapture_(this.id, 'set', 'Contrast', value);
        end

        function value = get.Saturation(this)
            value = VideoCapture_(this.id, 'get', 'Saturation');
        end
        function set.Saturation(this, value)
            VideoCapture_(this.id, 'set', 'Saturation', value);
        end

        function value = get.Hue(this)
            value = VideoCapture_(this.id, 'get', 'Hue');
        end
        function set.Hue(this, value)
            VideoCapture_(this.id, 'set', 'Hue', value);
        end

        function value = get.Gain(this)
            value = VideoCapture_(this.id, 'get', 'Gain');
        end
        function set.Gain(this, value)
            VideoCapture_(this.id, 'set', 'Gain', value);
        end

        function value = get.Exposure(this)
            value = VideoCapture_(this.id, 'get', 'Exposure');
        end
        function set.Exposure(this, value)
            VideoCapture_(this.id, 'set', 'Exposure', value);
        end

        function value = get.ConvertRGB(this)
            value = VideoCapture_(this.id, 'get', 'ConvertRGB');
        end
        function set.ConvertRGB(this, value)
            VideoCapture_(this.id, 'set', 'ConvertRGB', value);
        end

        function value = get.Rectification(this)
            value = VideoCapture_(this.id, 'get', 'Rectification');
        end
        function set.Rectification(this, value)
            VideoCapture_(this.id, 'set', 'Rectification', value);
        end
    end

end
