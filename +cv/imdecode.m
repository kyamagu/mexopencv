%IMDECODE  Reads an image from a buffer in memory
%
%    img = cv.imdecode(buf)
%    img = cv.imdecode(buf, 'OptionName',optionValue, ...)
%
% ## Input
% * __buf__ Input byte array of an encoded image (`uint8` vector).
%
% ## Output
% * __img__ Decoded image.
%
% ## Options
% * __Unchanged__ If set, return the loaded image as is (with alpha channel,
%       otherwise it gets cropped). Both the depth and number of channels are
%       unchanged as determined by the decoder. default false
% * __AnyDepth__ If set, return 16-bit/32-bit image when the input has the
%       corresponding depth, otherwise convert it to 8-bit. default false
% * __AnyColor__ If set, the image is read in any possible color format.
%       default false
% * __Color__ If set, always convert image to the 3 channel BGR color image.
%       default true
% * __Grayscale__ If set, always convert image to the single channel grayscale
%       image. default false
% * __Flags__ Advanced option to directly set the flag specifying the depth
%       and color type of a loaded image. Note that setting this integer flag
%       overrides all the other flag options. Not set by default:
%       * `>0`: Return a 3-channel color image. Note that in the current
%               implementation the alpha channel, if any, is stripped from the
%               output image. For example, a 4-channel RGBA image is loaded as
%               RGB if `Flags >= 0`.
%       * `=0`: Return a grayscale image
%       * `<0`: Return the loaded image as is (with alpha channel if present).
% * __FlipChannels__ in case the output is color image, flips the color order
%       from OpenCV's BGR/BGRA to MATLAB's RGB/RGBA order. default true
%
% The function reads an image from the specified buffer in the memory. If
% the buffer is too short or contains invalid data, an error is thrown.
%
% See cv.imread for the list of supported formats and flags description.
%
% ## Note
% In the case of color images, the decoded images will have the channels
% stored in BGR order. If `FlipChannels` is true, the order is flipped to
% RGB.
%
% See also: cv.imencode, cv.imread
%
