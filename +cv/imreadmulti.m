%IMREADMULTI  Loads a multi-page image from a file
%
%    imgs = cv.imreadmulti(filename)
%    imgs = cv.imreadmulti(filename, 'OptionName',optionValue, ...)
%
% ## Input
% * __filename__ Name of file to be loaded.
%
% ## Output
% * __imgs__ A cell-array of images holding each page, if more than one. If
%       If the image cannot be read (because of IO errors, improper
%       permissions, unsupported or invalid format), the function throws an
%       error.
%
% ## Options
% * __Unchanged__ If set, return the loaded image as is (with alpha channel,
%       otherwise it gets cropped). Both the depth and number of channels are
%       unchanged as determined by the decoder. default false
% * __AnyDepth__ If set, return 16-bit/32-bit image when the input has the
%       corresponding depth, otherwise convert it to 8-bit. default false
% * __AnyColor__ If set, the image is read in any possible color format.
%       default true
% * __Color__ If set, always convert image to the 3 channel BGR color image.
%       default false
% * __Grayscale__ If set, always convert image to the single channel grayscale
%       image. default false
% * __GDAL__ If set, use the gdal driver for loading the image. default false
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
% See cv.imread for details.
%
% See also: cv.imread, imread
%
