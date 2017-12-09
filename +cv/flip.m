%FLIP  Flips a 2D array around vertical, horizontal, or both axes
%
%     dst = cv.flip(src, flipCode)
%
% ## Input
% * __src__ input array.
% * __flipCode__ a flag to specify how to flip the array:
%   * 0 means flipping around the x-axis
%   * positive value (for example, 1) means flipping around y-axis.
%   * Negative value (for example, -1) means flipping around both axes.
%
% ## Output
% * __dst__ output array of the same size and type as `src`.
%
% The function cv.flip flips the array in one of three different ways (row
% and column indices are 0-based):
%
%                { src(size(src,1)-i-1,j)                if flipCode = 0
%     dst(i,j) = { src(i,size(src,2)-j-1)                if flipCode > 0
%                { src(size(src,1)-i-1,size(src,2)-j-1)  if flipCode < 0
%
% The example scenarios of using the function are the following:
%
% * Vertical flipping of the image (`flipCode == 0`) to switch between
%   top-left and bottom-left image origin. This is a typical operation in
%   video processing on Microsoft Windows OS.
% * Horizontal flipping of the image with the subsequent horizontal shift
%   and absolute difference calculation to check for a vertical-axis
%   symmetry (`flipCode > 0`).
% * Simultaneous horizontal and vertical flipping of the image with the
%   subsequent shift and absolute difference calculation to check for a
%   central symmetry (`flipCode < 0`).
% * Reversing the order of point arrays (flipCode > 0 or flipCode == 0).
%
% See also: cv.rotate, flip, fliplr, flipud, rot90, transpose
%
