classdef VideoWriter < handle
    %VIDEOWRITER  Video Writer class
    %
    % The class provides API for writing video files or image sequences.
    %
    % Note: When querying a property that is not supported by the backend
    % used by the cv.VideoWriter instance, value 0 is returned.
    %
    % ## Example
    % Here is how to write to a video file:
    %
    %     vid = cv.VideoWriter('myvideo.mpg', [640,480]);
    %     vid.write(im);         % add a frame
    %     clear vid;             % finish
    %
    % See also: cv.VideoWriter.VideoWriter, cv.VideoWriter.write,
    %  cv.VideoCapture, VideoWriter, avifile, movie2avi,
    %  vision.VideoFileWriter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Current quality (0..100%) of the encoded videostream. Can be
        % adjusted dynamically in some codecs.
        Quality

        % Number of stripes for parallel encoding. -1 for auto detection
        NStripes
    end

    properties (Dependent, SetAccess = private)
        % Size of just encoded video frame; note that the encoding order may
        % be different from representation order.
        FrameBytes
    end

    methods
        function this = VideoWriter(varargin)
            %VIDEOWRITER  VideoWriter constructor
            %
            %     vid = cv.VideoWriter()
            %     vid = cv.VideoWriter(filename, frameSize)
            %     vid = cv.VideoWriter(filename, frameSize, 'OptionName',optionValue, ...)
            %
            % ## Output
            % * __vid__ New instance of the VideoWriter
            %
            % The constructor initializes a video writer. When arguments are
            % supplied, the constructor calls the cv.VideoWriter.open method
            % right after creating the object.
            %
            % Accepts the same inputs and options as the cv.VideoWriter.open
            % method.
            %
            % See also: cv.VideoWriter.open, cv.VideoWriter.write
            %
            this.id = VideoWriter_(0, 'new');
            if nargin > 0
                this.open(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     vid.delete()
            %
            % The method first calls cv.VideoWriter.release to close the
            % already opened file.
            %
            % See also: cv.VideoWriter.release
            %
            if isempty(this.id), return; end
            VideoWriter_(this.id, 'delete');
        end

        function successFlag = open(this, filename, frameSize, varargin)
            %OPEN  Initializes or reinitializes video writer
            %
            %     successFlag = vid.open(filename, frameSize)
            %     successFlag = vid.open(filename, frameSize, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ Name of the output video file
            % * __frameSize__ Size of the video frames `[width, height]`.
            %
            % ## Output
            % * __successFlag__ bool, true if video writer has been
            %   successfully initialized.
            %
            % ## Options
            % * __API__ The parameter allows to specify API backends to use.
            %   Can be used to enforce a specific writer implementation if
            %   multiple are available: e.g. 'FFMPEG' or 'GStreamer'
            %   * __Any__ (default) Auto detect
            %   * __VfW__ Video For Windows
            %   * __QuickTime__ QuickTime
            %   * __AVFoundation__ AVFoundation framework for iOS
            %   * __MediaFoundation__ Microsoft Media Foundation
            %   * __GStreamer__ GStreamer
            %   * __FFMPEG__ FFMPEG library
            %   * __Images__ OpenCV Image Sequence (e.g. `img_%02d.jpg`)
            %   * __MotionJPEG__ Built-in OpenCV MotionJPEG codec
            %   * __MediaSDK__ Intel Media SDK
            % * __FourCC__ 4-character code of codec used to compress the
            %   frames. List of codes can be obtained at [FOURCC]. FFMPEG
            %   backend with MP4 container natively uses other values as
            %   FourCC code: see [ObjectType], so you may receive a warning
            %   message from OpenCV about fourcc code conversion. Examples are:
            %   * __PIM1__ MPEG-1 codec
            %   * __MJPG__ Motion-JPEG codec (default)
            %   * __MP42__ MPEG-4 (Microsoft)
            %   * __DIV3__ DivX MPEG-4 Part 2
            %   * __DIVX__ DivX codec
            %   * __XVID__ XVID MPEG-4 Part 2
            %   * __U263__ H263
            %   * __I263__ ITU H.263
            %   * __FLV1__ Sorenson Spark (Flash Video)
            %   * __X264__ H.264
            %   * __AVC1__ MPEG-4 Part 10/H.264 (Apple)
            %   * __WMV1__ Windows Media Video 7 (Microsoft)
            %   * __WMV2__ Windows Media Video 8 (Microsoft)
            %   * __-1__ prompts with codec selection dialog (Windows only)
            % * __FPS__ Framerate of the created video stream. default 25.
            % * __Color__ If true, the encoder will expect and encode color
            %   frames, otherwise it will work with grayscale frames (the flag
            %   is currently supported on Windows only). default true
            %
            % The method first calls cv.VideoWriter.release to close the
            % already opened file.
            %
            % The method opens a video writer:
            %
            % * On Linux FFMPEG is used to write videos;
            % * On Windows FFMPEG or VFW is used;
            % * On MacOSX QTKit is used.
            %
            % ### Tips
            % * With some backends `FourCC=-1` pops up the codec selection
            %   dialog from the system.
            % * To save image sequence use a proper filename (eg.
            %   `img_%02d.jpg`) and `FourCC=0` OR `FPS=0`. Use uncompressed
            %   image format (eg. `img_%02d.BMP`) to save raw frames.
            % * Most codecs are lossy. If you want lossless video file you
            %   need to use a lossless codecs (eg. FFMPEG FFV1, Huffman HFYU,
            %   Lagarith LAGS, etc...)
            % * If FFMPEG is enabled, using `codec=0; fps=0;` you can create
            %   an uncompressed (raw) video file.
            %
            % ## References
            % [FOURCC]:
            % > Video Codecs by [FOURCC](http://www.fourcc.org/codecs.php)
            %
            % [ObjectType]:
            % > [Codecs](http://www.mp4ra.org/codecs.html)
            %
            % See also: cv.VideoWriter.VideoWriter, cv.VideoWriter.isOpened
            %
            successFlag = VideoWriter_(this.id, 'open', filename, frameSize, varargin{:});
        end

        function retval = isOpened(this)
            %ISOPENED  Returns true if video writer has been successfully initialized
            %
            %     retval = vid.isOpened()
            %
            % ## Output
            % * __val__ bool, return value
            %
            % Returns true if video writer has been successfully initialized.
            %
            % See also: cv.VideoWriter.open
            %
            retval = VideoWriter_(this.id, 'isOpened');
        end

        function release(this)
            %RELEASE  Closes the video writer
            %
            %     vid.release()
            %
            % The method is automatically called by subsequent
            % cv.VideoWriter.open and by the cv.VideoWriter destructor.
            %
            % See also: cv.VideoWriter.open
            %
            VideoWriter_(this.id, 'release');
        end

        function write(this, frame, varargin)
            %WRITE  Writes the next video frame
            %
            %     vid.write(frame)
            %     vid.write(frame, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __frame__ The written frame
            %
            % ## Options
            % * __FlipChannels__ in case the input is color image, flips the
            %   color order from MATLAB's RGB to OpenCV's BGR order.
            %   default true
            %
            % The method writes the specified image to video file. It must
            % have the same size as has been specified when opening the video
            % writer.
            %
            % See also: cv.VideoWriter.open
            %
            VideoWriter_(this.id, 'write', frame, varargin{:});
        end

        function value = get(this, prop)
            %GET  Returns the specified VideoWriter property
            %
            %     value = vid.get(prop)
            %
            % ## Input
            % * __prop__ Property identifier. It can be specified as a string
            %   (one of the recognized properties), or directly as its
            %   corresponding integer code.
            %
            % ## Output
            % * __value__ Value for the specified property (as a `double`).
            %   Value 0 is returned when querying a property that is not
            %   supported by the backend used by the VideoWriter instance.
            %
            % See also: cv.VideoWriter.set
            %
            value = VideoWriter_(this.id, 'get', prop);
        end

        function set(this, prop, value)
            %SET  Sets a property in the VideoWriter
            %
            %     vid.set(prop, value)
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
            % See also: cv.VideoWriter.get
            %
            VideoWriter_(this.id, 'set', prop, value);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Quality(this)
            value = VideoWriter_(this.id, 'get', 'Quality');
        end
        function set.Quality(this, value)
            VideoWriter_(this.id, 'set', 'Quality', value);
        end

        function value = get.NStripes(this)
            value = VideoWriter_(this.id, 'get', 'NStripes');
        end
        function set.NStripes(this, value)
            VideoWriter_(this.id, 'set', 'NStripes', value);
        end

        function value = get.FrameBytes(this)
            value = VideoWriter_(this.id, 'get', 'FrameBytes');
        end
    end

end
