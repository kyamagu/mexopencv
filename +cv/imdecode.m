%IMDECODE  Reads an image from a buffer in memory
%
%    img = cv.imdecode(buf)
%    img = cv.imdecode(buf, 'Flags', flags)
%
% ## Input
% * __buf__ Input array of an encoded image.
%
% ## Output
% * __img__ Decoded image.
%
% ## Options
% * __Flags__ Flags specifying the color type of a loaded image.
%      >0: Return a 3-channel color image
%      =0: Return a grayscale image
%      <0: Return the loaded image as is. Note that in the current
%          implementation the alpha channel, if any, is stripped from the output
%          image. For example, a 4-channel RGBA image is loaded as RGB if
%          flags >= 0.
%
% The function reads an image from the specified buffer in the memory. If
% the buffer is too short or contains invalid data, the empty matrix/image
% is returned.
%
% See cv.imread for the list of supported formats and flags description.
%
% See also cv.imdecode cv.imread cv.imwrite
%
