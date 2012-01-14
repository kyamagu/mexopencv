classdef VideoCapture < handle
	%VIDEOCAPTURE  VideoCapture wrapper class
	%
	% Class for video capturing from video files or cameras. The class
	% provides Matlab API for capturing video from cameras or for reading
	% video files. Here is how the class can be used:
	%
	%   cap = cv.VideoCapture; % default camera
	%   pause(3); % There seems a concurrency issue in cv::VideoCapture.
	%             % Wait seconds to make sure a camera is complete.
	%   for t = 1:30
	%      im = cap.read();
	%      imshow(im);
	%      pause(0.1);
	%   end
	%   clear cap; % Destroy if you want to turn off the camera
	%   
	% Currently it cannot have two instances of the VideoCapture at the
	% same time
    
    methods
        function this = VideoCapture(filename)
            %VIDEOCAPTURE  Create a new VideoCapture object
            if nargin < 1, filename = 0; end
            if ~cv.VideoCapture_('open', filename)
                error('VideoCapture:open','Could not open a video');
            end
        end
        
        function delete(this)
            %DELETE  Destructor of VideoCapture object
            cv.VideoCapture_('release');
        end
        
        function frame = read(this)
            %READ  Grabs, decodes and returns the next video frame
            frame = cv.VideoCapture_('read');
        end
        
        function value = get(this, key)
            %GET  Returns the specified VideoCapture property
            value = cv.VideoCapture_('get', key);
        end
        
        function set(this, key, value)
            %GET  Returns the specified VideoCapture property
            cv.VideoCapture_('set', key, value);
        end
    end
    
end
