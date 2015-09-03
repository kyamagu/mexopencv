%WRITEOPTICALFLOW  Write a .flo to disk
%
%    cv.writeOpticalFlow(path, flow)
%    success = cv.writeOpticalFlow(path, flow)
%
% ## Input
% * __path__ Path to the file to be written.
% * __flow__ Flow field to be stored.
%
% ## Output
% * __success__ true on success, false otherwise.
%
% Function for writing .flo files in "Middlebury" format, see:
% http://vision.middlebury.edu/flow/code/flow-code/README.txt
%
% The function stores a flow field in a file, returns true on success, false
% otherwise. The flow field must be a 2-channel, `single` floating-point
% matrix. First channel corresponds to the flow in the horizontal direction
% (`u`), second - vertical (`v`).
%
% See also: cv.readOpticalFlow
%
