%APPLYCHANNELGAINS  Implements an efficient fixed-point approximation for applying channel gains, which is the last step of multiple white balance algorithms
%
%     dst = cv.applyChannelGains(src, gains)
%
% ## Input
% * __src__ Input 3-channel image in the BGR color space (either `uint8` or
%   `uint16`).
% * __gains__ gains for the [B,G,R] channels.
%
% ## Output
% * __dst__ Output image of the same size and type as `src`.
%
% See also: cv.GrayworldWB, cv.LearningBasedWB, imapplymatrix
%
