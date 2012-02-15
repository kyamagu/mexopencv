%IMREAD  Loads an image from a file
%
%    dst = cv.imread(filename)
%    dst = cv.imread(filename, 'Flags', flags)
%
% ## Input
% * __filename__ Name of a file to be loaded.
%
% ## Output
% * __dst__ Loaded image.
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
% The function imread loads an image from the specified file and returns it. If
% the image cannot be read (because of missing file, improper permissions,
% unsupported or invalid format), the function returns an empty matrix.
% Currently, the following file formats are supported:
%
%     Windows bitmaps - *.bmp, *.dib (always supported)
%     JPEG files - *.jpeg, *.jpg, *.jpe (see the Notes section)
%     JPEG 2000 files - *.jp2 (see the Notes section)
%     Portable Network Graphics - *.png (see the Notes section)
%     Portable image format - *.pbm, *.pgm, *.ppm (always supported)
%     Sun rasters - *.sr, *.ras (always supported)
%     TIFF files - *.tiff, *.tif (see the Notes section)
%
% ## Notes
% The function determines the type of an image by the content, not by the file
% extension.
% 
% On Microsoft Windows* OS and MacOSX*, the codecs shipped with an OpenCV image
% (libjpeg, libpng, libtiff, and libjasper) are used by default. So, OpenCV can
% always read JPEGs, PNGs, and TIFFs. On MacOSX, there is also an option to use
% native MacOSX image readers. But beware that currently these native image
% loaders give images with different pixel values because of the color
% management embedded into MacOSX.
%
% On Linux*, BSD flavors and other Unix-like open-source operating systems,
% OpenCV looks for codecs supplied with an OS image. Install the relevant
% packages (do not forget the development files, for example, libjpeg-dev,
% in Debian* and Ubuntu*) to get the codec support or turn on the
% `OPENCV_BUILD_3RDPARTY_LIBS` flag in CMake.
%
% See also cv.imwrite
%
