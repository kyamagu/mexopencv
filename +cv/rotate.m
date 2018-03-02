%ROTATE  Rotates a 2D array in multiples of 90 degrees
%
%     dst = cv.rotate(src, rotateCode)
%
% ## Input
% * __src__ input array.
% * __rotateCode__ an enum to specify how to rotate the array:
%   * __90CW__ Rotate 90 degrees clockwise
%   * __180__ Rotate 180 degrees clockwise
%   * __90CCW__ Rotate 270 degrees clockwise
%
% ## Output
% * __dst__ output array of the same type as `src`. The size is the same with
%   '180', and the rows and cols are switched for '90CW' and '90CCW'.
%
% The function cv.rotate rotates the array in one of three different ways:
%
% * Rotate by 90 degrees clockwise (`rotateCode = '90CW'`).
% * Rotate by 180 degrees clockwise (`rotateCode = '180'`).
% * Rotate by 270 degrees clockwise (`rotateCode = '90CCW'`).
%
% See also: cv.flip, transpose, rot90, flip
%
