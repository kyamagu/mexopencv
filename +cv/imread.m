%IMREAD  Loads an image from a file
%
%    img = cv.imread(filename)
%    img = cv.imread(filename, 'OptionName',optionValue, ...)
%
% ## Input
% * __filename__ Name of a file to be loaded.
%
% ## Output
% * __img__ Loaded image, whose depth and number of channels depend on options.
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
% The function cv.imread loads an image from the specified file and returns
% it. If the image cannot be read (because of missing file, improper
% permissions, unsupported or invalid format), the function issues an error.
% Currently, the following file formats are supported:
%
% * Windows bitmaps - `*.bmp`, `*.dib` (always supported)
% * JPEG files - `*.jpeg`, `*.jpg`, `*.jpe` (see the Notes section)
% * JPEG 2000 files - `*.jp2` (see the Notes section)
% * Portable Network Graphics - `*.png` (see the Notes section)
% * WebP - `*.webp` (see the Notes section)
% * Portable image format - `*.pbm`, `*.pgm`, `*.ppm`, `*.pxm`, `*.pnm`
%   (always supported)
% * Sun rasters - `*.sr`, `*.ras` (always supported)
% * TIFF files - `*.tiff`, `*.tif` (see the Notes section)
% * OpenEXR Image files - `*.exr` (see the Notes section)
% * Radiance HDR - `*.hdr`, `*.pic` (always supported)
%
% ## Note
% The function determines the type of an image by the content, not by the file
% extension.
%
% On Microsoft Windows OS and MacOSX, the codecs shipped with an OpenCV image
% (libjpeg, libpng, libtiff, and libjasper) are used by default. So, OpenCV can
% always read JPEGs, PNGs, and TIFFs. On MacOSX, there is also an option to use
% native MacOSX image readers. But beware that currently these native image
% loaders give images with different pixel values because of the color
% management embedded into MacOSX.
%
% On Linux, BSD flavors and other Unix-like open-source operating systems,
% OpenCV looks for codecs supplied with an OS image. Install the relevant
% packages (do not forget the development files, for example, "libjpeg-dev",
% in Debian and Ubuntu) to get the codec support or turn on the
% `OPENCV_BUILD_3RDPARTY_LIBS` flag in CMake.
%
% In the case of color images, the decoded images will have the channels
% stored in BGR order. If `FlipChannels` is set, the channels are flipped to
% RGB order
%
% See also: cv.imwrite, cv.imdecode, imread, imfinfo, imformats
%
