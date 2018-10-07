classdef VideoCapture < handle
    %VIDEOCAPTURE  Class for video capturing from video files or cameras
    %
    % The class provides an API for capturing video from cameras or for
    % reading video files and image sequences.
    %
    % ## Example
    % Here is how the class can be used:
    %
    %     cap = cv.VideoCapture(0);        % open the default camera
    %     pause(3);                        % see note below
    %     if ~cap.isOpened()               % check if we succeeded
    %         error('camera failed to initialized');
    %     end
    %     for t=1:30
    %         frame = cap.read();           % get a new frame from camera
    %         imshow(frame);
    %         pause(0.1);
    %     end
    %     % the camera will be deinitialized automatically in destructor
    %     % when "cap" goes out of scope
    %     % you can also explicitly call cap.release() to close the camera
    %
    % Note: In some environments, there is a concurrency issue during camera
    % initialization. To avoid unexpected crash, pause for a few seconds after
    % the initialization of cv.VideoCapture object.
    %
    % # Video I/O with OpenCV Overview
    %
    % The OpenCV "videoio" module is a set of classes and functions to read
    % and write video or images sequence.
    %
    % Basically, the module provides the cv.VideoCapture and cv.VideoWriter
    % classes as 2-layer interface to many video I/O APIs used as backend.
    %
    % ![image](https://docs.opencv.org/3.3.1/videoio_overview.svg)
    %
    % Some backends such as (`DirectShow`) Direct Show, Video For Windows
    % (`VfW`), Microsoft Media Foundation (`MediaFoundation`), Video 4 Linux
    % (`V4L`), etc... are interfaces to the video I/O library provided by the
    % operating system.
    %
    % Some others backends like OpenNI2 for Kinect, Intel Perceptual Computing
    % SDK, GStreamer, XIMEA Camera API, etc... are interfaces to proprietary
    % drivers or to external library.
    %
    % See the list of supported backends here: cv.VideoCapture.open
    %
    % Warning: Some backends are experimental use them at your own risk.
    % Note: Each backend supports devices properties (cv.VideoCapture.set) in
    % a different way or might not support any property at all.
    %
    % ## Select the backend at runtime
    % OpenCV automatically selects and uses first available backend
    % (`API='Any'`).
    %
    % As advanced usage you can select the backend to use at runtime.
    % Currently this option is available only with cv.VideoCapture.
    %
    % For example to grab from default camera using Direct Show as backend
    %
    %     % declare a capture object
    %     cap = cv.VideoCapture(0, 'API','DirectShow')
    %
    %     % or specify the API preference with open
    %     cap.open(0, 'API','DirectShow');
    %
    % If you want to grab from a file using the Direct Show as backend:
    %
    %     % declare a capture object
    %     cap = cv.VideoCapture(filename, 'API','DirectShow')
    %
    %     % or specify the API preference with open
    %     cap.open(filename, 'API','DirectShow');
    %
    % ### Enable backends
    % Backends are available only if they have been built with your OpenCV
    % binaries.
    %
    % Check in `opencv2/cvconfig.h` to know which APIs are currently available
    % (e.g. `HAVE_MSMF, HAVE_VFW, HAVE_LIBV4L`, etc...).
    %
    % To enable/disable APIs, you have to:
    % 1. re-configure OpenCV using appropriates CMake switches
    %    (e.g. `-DWITH_MSMF=ON -DWITH_VFW=ON ... `) or checking related switch
    %    in cmake-gui
    % 2. rebuild OpenCV itself
    %
    % ### Use 3rd party drivers or cameras
    % Many industrial cameras or some video I/O devices don't provide standard
    % driver interfaces for the operating system. Thus you can't use
    % cv.VideoCapture or cv.VideoWriter with these devices.
    %
    % ## The FFmpeg library
    % OpenCV can use the [FFmpeg](http://ffmpeg.org/) library as backend to
    % record, convert and stream audio and video. FFMpeg is a complete,
    % cross-reference solution. If you enable FFmpeg while configuring OpenCV
    % than CMake will download and install the binaries in
    % `OPENCV_SOURCE_CODE/3rdparty/ffmpeg/`. To use FFMpeg at runtime, you
    % must deploy the FFMepg binaries with your application.
    %
    % Note: FFmpeg is licensed under the GNU Lesser General Public License
    % (LGPL) version 2.1 or later. See
    % `OPENCV_SOURCE_CODE/3rdparty/ffmpeg/readme.txt` and
    % http://ffmpeg.org/legal.html for details and licensing information.
    %
    % See also: cv.VideoCapture.VideoCapture, cv.VideoCapture.read,
    %  cv.VideoWriter, VideoReader, mmreader, aviread, webcam, videoinput,
    %  imaq.VideoDevice, vision.VideoFileReader
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
        % 4-character code of codec. See cv.VideoWriter.open.
        FourCC
        % Number of frames in the video file.
        FrameCount
        % Format of the frames returned by cv.VideoCapture.retrieve.
        Format
        % Backend-specific value indicating the current capture mode.
        Mode
        % Brightness of the image (only for those cameras that support it).
        Brightness
        % Contrast of the image (only for cameras).
        Contrast
        % Saturation of the image (only for cameras).
        Saturation
        % Hue of the image (only for cameras).
        Hue
        % Gain of the image (only for those cameras that support it).
        Gain
        % Exposure (only for those cameras that support it).
        Exposure
        % Boolean flags indicating whether images should be converted to RGB.
        ConvertRGB
        % Rectification flag for stereo cameras
        % (note: only supported by DC1394 v2.x backend currently)
        Rectification
    end

    methods
        function this = VideoCapture(varargin)
            %VIDEOCAPTURE  Open video file or a capturing device or a IP video stream for video capturing
            %
            %     cap = cv.VideoCapture()
            %     cap = cv.VideoCapture(index)
            %     cap = cv.VideoCapture(filename)
            %     cap = cv.VideoCapture(..., 'API',apiPreference)
            %
            % ## Output
            % * __cap__ New instance of the VideoCapture
            %
            % Accepts the same inputs and options as the cv.VideoCapture.open
            % method.
            %
            % Creates a new video capture instance. With no argument, it
            % connects to the default camera device found in the system.
            % You can specify camera devices by `index`, an integer value
            % starting from 0. You can also specify a `filename` to open a
            % video file.
            %
            % See also: cv.VideoCapture.open
            %
            this.id = VideoCapture_(0, 'new');
            if nargin > 0
                this.open(varargin{:});
            else
                this.open(0);
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     cap.delete()
            %
            % The method first calls cv.VideoCapture.release to close the
            % already opened file or camera.
            %
            % See also: cv.VideoCapture.release
            %
            if isempty(this.id), return; end
            VideoCapture_(this.id, 'delete');
        end

        function successFlag = open(this, index, varargin)
            %OPEN  Open video file or a capturing device or a IP video stream for video capturing
            %
            %     successFlag = cap.open(index)
            %     successFlag = cap.open(filename)
            %     successFlag = cap.open(..., 'API',apiPreference)
            %
            % ## Input
            % * __index__ id of the video capturing device to open. To open
            %   default camera using default backend just pass 0.
            % * __filename__ it can be:
            %   * name of video file (eg. `video.avi`)
            %   * or image sequence (eg. `img_%02d.jpg`, which will read
            %     samples like `img_00.jpg`, img_01.jpg`, img_02.jpg`, ...)
            %   * or URL of video stream
            %     (eg. `protocol://host:port/script_name?script_params|auth`).
            %     Note that each video stream or IP camera feed has its own
            %     URL scheme. Please refer to the documentation of source
            %     stream to know the right URL.
            %   * or device name (for backends like V4L or gPhoto2)
            %
            % ## Output
            % * __successFlag__ bool, true if the file/camera has been
            %   successfully opened.
            %
            % ## Options
            % * __API__ preferred capture API backend to use. Can be used to
            %   enforce a specific reader implementation if multiple are
            %   available: e.g. 'FFMPEG' or 'Images' or 'DirectShow'. The list
            %   of supported API backends:
            %   * __Any__ Auto detect. This is the default.
            %   * __VfW__ Video For Windows (platform native).
            %   * __V4L__ V4L/V4L2 capturing support via libv4l.
            %   * __V4L2__ Same as V4L.
            %   * __FireWire__ IEEE 1394 drivers.
            %   * __FireWare__ Same as FireWire.
            %   * __IEEE1394__ Same as FireWire.
            %   * __DC1394__ Same as FireWire.
            %   * __CMU1394__ Same as FireWire.
            %   * __QuickTime__ QuickTime.
            %   * __Unicap__ Unicap drivers.
            %   * __DirectShow__ DirectShow (via videoInput).
            %   * __PvAPI__ PvAPI, Prosilica GigE SDK.
            %   * __OpenNI__ OpenNI (for Kinect).
            %   * __OpenNIAsus__ OpenNI (for Asus Xtion).
            %   * __Android__ Android - not used.
            %   * __XIMEA__ XIMEA Camera API.
            %   * __AVFoundation__ AVFoundation framework for iOS
            %     (OS X Lion will have the same API).
            %   * __Giganetix__ Smartek Giganetix GigEVisionSDK.
            %   * __MediaFoundation__ Microsoft Media Foundation
            %     (via videoInput).
            %   * __WinRT__ Microsoft Windows Runtime using Media
            %     Foundation.
            %   * __IntelPerC__ Intel Perceptual Computing SDK.
            %   * __OpenNI2__ OpenNI2 (for Kinect).
            %   * __OpenNI2Asus__ OpenNI2 (for Asus Xtion and Occipital
            %     Structure sensors).
            %   * __gPhoto2__ gPhoto2 connection.
            %   * __GStreamer__ GStreamer.
            %   * __FFMPEG__ Open video file or stream using the FFMPEG
            %     library.
            %   * __Images__ OpenCV Image Sequence (e.g. `img_%02d.jpg`).
            %   * __Aravis__ Aravis GigE SDK.
            %   * __MotionJPEG__ Built-in OpenCV MotionJPEG codec.
            %   * __MediaSDK__ Intel MediaSDK.
            %
            % The method first calls cv.VideoCapture.release to close the
            % already opened file or camera.
            %
            % ## Example
            % Use `API` option to enforce a specific reader implementation
            % if multiple are available like 'FFMPEG' or 'Images' or
            % 'DirectShow'. For example, to open camera 1 using the
            % "MS Media Foundation" API:
            %
            %     cap.open(1, 'API','MediaFoundation')
            %
            % ### Note
            % Backends are available only if they have been built with your
            % OpenCV binaries.
            % Check your build to know which APIs are currently available.
            % To enable/disable APIs, you have to re-configure OpenCV using
            % the appropriates CMake switches and recompile OpenCV itself.
            %
            % See also: cv.VideoCapture.VideoCapture, cv.VideoCapture.isOpened
            %
            if nargin < 1, index = 0; end
            successFlag = VideoCapture_(this.id, 'open', index, varargin{:});
        end

        function retval = isOpened(this)
            %ISOPENED  Returns true if video capturing has been initialized already
            %
            %     retval = cap.isOpened()
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
            %     cap.release()
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
            %     frame = cap.read()
            %     frame = cap.read('OptionName',optionValue, ...)
            %
            % ## Output
            % * __frame__ output image
            %
            % ## Options
            % * __FlipChannels__ in case the output is color image, flips the
            %   color order from OpenCV's BGR to MATLAB's RGB order.
            %   default true
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
            %     successFlag = cap.grab()
            %
            % ## Output
            % * __successFlag__ bool, true (non-zero) in the case of success.
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
            %     frame = cap.retrieve()
            %     frame = cap.retrieve('OptionName',optionValue, ...)
            %
            % ## Output
            % * __frame__ the video frame is returned here. If no frames has
            %   been grabbed the image will be empty.
            %
            % ## Options
            % * __StreamIdx__ 0-based index (for multi-head camera). It could
            %   be a frame index or a driver specific flag. default 0
            % * __FlipChannels__ in case the output is color image, flips the
            %   color order from OpenCV's BGR to MATLAB's RGB order.
            %   default true
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

        function value = get(this, prop)
            %GET  Returns the specified VideoCapture property
            %
            %     value = cap.get(prop)
            %
            % ## Input
            % * __prop__ Property identifier. It can be specified as a string
            %   (one of the recognized properties), or directly as its
            %   corresponding integer code.
            %
            % ## Output
            % * __value__ Value for the specified property (as a `double`).
            %   Value 0 is returned when querying a property that is not
            %   supported by the backend used by the VideoCapture instance.
            %
            % ### Note
            % Reading/writing properties involves many layers. Some unexpected
            % result might happens along this chain.
            % `VideoCapture -> API Backend -> Operating System -> Device Driver -> Device Hardware`
            % The returned value might be different from what really used by
            % the device or it could be encoded using device dependent rules
            % (eg. steps or percentage). Effective behaviour depends from
            % device driver and API Backend.
            %
            % ## Example
            % All the following are equivalent:
            %
            %     b = cap.Brightness
            %     b = cap.get('Brightness')
            %     b = cap.get(10)  % enum value defined in OpenCV source code
            %
            % See also: cv.VideoCapture.set
            %
            value = VideoCapture_(this.id, 'get', prop);
        end

        function set(this, prop, value)
            %SET  Sets a property in the VideoCapture
            %
            %     cap.set(prop, value)
            %
            % ## Input
            % * __prop__ Property identifier. It can be specified as a string
            %   (one of the recognized properties), or directly as its
            %   corresponding integer code.
            % * __value__ Value of the property (as a `double`).
            %
            % On failure (unsupported property by backend), the function
            % issues a warning.
            %
            % Note: Even if no warning was issued, this doesn't ensure that
            % the property value has been accepted by the capture device.
            % See note in cv.VideoCapture.get.
            %
            % See also: cv.VideoCapture.get
            %
            VideoCapture_(this.id, 'set', prop, value);
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
