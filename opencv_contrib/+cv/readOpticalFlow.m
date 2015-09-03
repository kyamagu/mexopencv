%READOPTICALFLOW  Read a .flo file
%
%    flow = cv.readOpticalFlow(path)
%
% ## Input
% * __path__ Path to the file to be loaded.
%
% ## Output
% * __flow__ Flow field of `single` floating-point type, 2-channel. First
%       channel corresponds to the flow in the horizontal direction (`u`),
%       second - vertical (`v`).
%
% Function for reading .flo files in "Middlebury" format, see:
% http://vision.middlebury.edu/flow/code/flow-code/README.txt
%
% The function cv.readOpticalFlow loads a flow field from a file and returns
% it as a single matrix.
%
% See also: cv.writeOpticalFlow
%
