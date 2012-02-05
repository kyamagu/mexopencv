classdef VideoWriter < handle
	%VIDEOWRITER  VideoWriter wrapper class
	%
	% Video writer class. Here is how to write to a video file:
	%
	%   vid = cv.VideoWriter('myvideo.mpg', [640,480]);
	%   vid.write(im);         % add a frame
	%   clear vid;             % finish
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
            %  vid = cv.VideoWriter(filename, siz)
            %  vid = cv.VideoWriter(filename, siz, 'option', option_value, ...)
            %
            % Input:
            %   filename: Name of the video file
            %   siz: Size of the video frame in [width, height] format
            % Output:
            %   vid: New instance of the VideoWriter
            % Options:
            %   'FourCC': 4-character code of codec used to compress the frames.
            %      Examples are:
            %       'PIM1': MPEG-1
            %		'MJPG': Motion-JPEG
            %		'MP42': MPEG-4.2
            %		'DIV3': MPEG-4.3
            %		'DIVX': MPEG-4
            %		'U263': H263 (default)
            %		'I263': H263I
            %		'FLV1': FLV1
            %	'FPS': Framerate of the created video stream. default 25.
            %   'Color': If it is not zero, the encoder will expect and encode
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
            %   vid.write(frame)
            %
            % Input:
            %   frame: The written frame
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
    
end
