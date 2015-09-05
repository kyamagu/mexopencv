classdef VideoWriter < handle
    %VIDEOWRITER  Video Writer class
    %
    % When querying a property that is not supported by the backend
    % used by the cv.VideoWriter class, value 0 is returned.
    %
    % ## Example
    % Here is how to write to a video file:
    %
    %    vid = cv.VideoWriter('myvideo.mpg', [640,480]);
    %    vid.write(im);         % add a frame
    %    clear vid;             % finish
    %
    % See also: cv.VideoWriter.VideoWriter, cv.VideoWriter.write,
    %  VideoWriter, avifile, movie2avi, vision.VideoFileWriter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Current quality (0..100%) of the encoded videostream. Can be
        % adjusted dynamically in some codecs.
        Quality
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
            %    vid = cv.VideoWriter()
            %    vid = cv.VideoWriter(filename, frameSize)
            %    vid = cv.VideoWriter(filename, frameSize, 'OptionName',optionValue, ...)
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
            %DELETE  VideoWriter destructor
            %
            % See also: cv.VideoWriter.release
            %
            VideoWriter_(this.id, 'delete');
        end

        function retval = open(this, filename, frameSize, varargin)
            %OPEN  Initializes or reinitializes video writer
            %
            %    retval = vid.open(filename, frameSize)
            %    retval = vid.open(filename, frameSize, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ Name of the output video file
            % * __frameSize__ Size of the video frames `[width, height]`.
            %
            % ## Output
            % * __retval__ bool, indicates if video is successfully initialized
            %
            % ## Options
            % * __FourCC__ 4-character code of codec used to compress the
            %       frames. List of codes can be obtained at [FOURCC].
            %       Examples are:
            %       * __PIM1__ MPEG-1 codec
            %       * __MJPG__ Motion-JPEG codec
            %       * __MP42__ MPEG-4 (Microsoft)
            %       * __DIV3__ DivX MPEG-4 Part 2
            %       * __DIVX__ DivX codec
            %       * __XVID__ XVID MPEG-4 Part 2
            %       * __U263__ H263 (default)
            %       * __I263__ ITU H.263
            %       * __FLV1__ Sorenson Spark (Flash Video)
            %       * __X264__ H.264
            %       * __AVC1__ MPEG-4 Part 10/H.264 (Apple)
            %       * __-1__ prompts with codec selection dialog (Windows only)
            % * __FPS__ Framerate of the created video stream. default 25.
            % * __Color__ If true, the encoder will expect and encode color
            %       frames, otherwise it will work with grayscale frames (the
            %       flag is currently supported on Windows only). default true
            %
            % The method opens a video writer. On Linux FFMPEG is
            % used to write videos; on Windows FFMPEG or VFW is used; on
            % MacOSX QTKit is used.
            %
            % ## References
            % [FOURCC]:
            % > "Video Codecs by FOURCC", http://www.fourcc.org/codecs.php
            %
            % See also: cv.VideoWriter.VideoWriter cv.VideoWriter.isOpened
            %
            retval = VideoWriter_(this.id, 'open', filename, frameSize, varargin{:});
        end

        function retval = isOpened(this)
            %ISOPENED  Returns true if video writer has been successfully initialized
            %
            %    retval = vid.isOpened()
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
            %    vid.release()
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
            %    vid.write(frame)
            %    vid.write(frame, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __frame__ The written frame
            %
            % ## Options
            % * __FlipChannels__ in case the input is color image, flips the
            %       color order from MATLAB's RGB to OpenCV's BGR order.
            %       default true
            %
            % The method writes the specified image to video file. It must
            % have the same size as has been specified when opening the video
            % writer.
            %
            % See also: cv.VideoWriter.open
            %
            VideoWriter_(this.id, 'write', frame, varargin{:});
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

        function value = get.FrameBytes(this)
            value = VideoWriter_(this.id, 'get', 'FrameBytes');
        end
    end

end
