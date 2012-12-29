classdef VideoWriter < handle
    %VIDEOWRITER  VideoWriter wrapper class
    %
    % Video writer class. Here is how to write to a video file:
    %
    %    vid = cv.VideoWriter('myvideo.mpg', [640,480]);
    %    vid.write(im);         % add a frame
    %    clear vid;             % finish
    %
    % See also cv.VideoWriter.VideoWriter cv.VideoWriter.write
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = VideoWriter(filename, siz, varargin)
            %VIDEOWRITER  VideoWriter constructors
            %
            %    vid = cv.VideoWriter(filename, siz)
            %    vid = cv.VideoWriter(filename, siz, 'option', option_value, ...)
            %
            % ## Input
            % * __filename__ Name of the video file
            % * __siz__ Size of the video frame in [width, height] format
            %
            % ## Output
            % * __vid__ New instance of the VideoWriter
            %
            % ## Options
            % * __FourCC__ 4-character code of codec used to compress the frames.
            %      Examples are:
            %     * __PIM1__ MPEG-1
            %     * __MJPG__ Motion-JPEG
            %     * __MP42__ MPEG-4.2
            %     * __DIV3__ MPEG-4.3
            %     * __DIVX__ MPEG-4
            %     * __U263__ H263 (default)
            %     * __I263__ H263I
            %     * __FLV1__ FLV1
            % * __FPS__ Framerate of the created video stream. default 25.
            % * __Color__ If it is not zero, the encoder will expect and encode
            %      color frames, otherwise it will work with grayscale frames
            %      (the flag is currently supported on Windows only). default
            %      true.
            %
            % VideoWriter create a video file. Use cv.VideoWriter.write to add
            % video frames.
            %
            % See also cv.VideoWriter cv.VideoWriter.write
            %
            if nargin < 1, filename = 0; end
            this.id = VideoWriter_(filename, siz, varargin{:});
        end
        
        function delete(this)
            %DELETE  VideoWriter destructor
            %
            % See also cv.VideoWriter
            %
            VideoWriter_(this.id, 'delete');
        end
        
        function write(this, frame)
            %WRITE  Writes the next video frame
            %
            %    vid.write(frame)
            %
            % ## Input
            % * __frame__ The written frame
            %
            % The method writes a frame to the video. The size of the frame
            % must be the same to the parameter specified in the
            % constructor.
            %
            % See also cv.VideoWriter
            %
            VideoWriter_(this.id, 'write', frame);
        end
    end

    methods (Hidden = true)
        function retval = open(this, filename, siz, varargin)
            %OPEN  Initializes or reinitializes video writer.
            %
            % ## Input
            % * __filename__ Name of the video file
            % * __siz__ Size of the video frame in [width, height] format
            %
            % ## Output
            % * __retval__ bool, indicates if video is successfully initialized
            %
            % The method opens video writer. Parameters are the same as
            % in the constructor.
            %
            % See also cv.VideoWriter cv.VideoWriter.isOpened
            %
            retval = VideoWriter_(this.id, 'open', filename, siz, varargin{:});
        end

        function retval = isOpened(this)
            %ISOPENED  Returns true if video writer has been successfully initialized.
            %
            % ## Output
            % * __val__ bool, return value
            %
            % Returns true if video writer has been successfully initialized.
            %
            % See also cv.VideoWriter cv.VideoWriter.open
            %
            retval = VideoWriter_(this.id, 'isOpened');
        end
    end

end
