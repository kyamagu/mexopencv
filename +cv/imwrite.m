%IMWRITE  Saves an image to a specified file
%
%    cv.imwrite(filename, src)
%    cv.imwrite(filename, src, 'OptionName', optionValue, ...)
%    status = cv.imwrite(...)
%
% ## Input
% * __filename__ Name of the file.
% * __src__ Image to be saved.
%
% ## Output
% * __status__ Logical value indicating success when true.
%
% ## Options
% Format-specific save parameters. The following parameters are currently
% supported
%
% * __JpegQuality__ For JPEG, it can be a quality from 0 to 100 (the higher
%          is the better). Default value is 95.
% * __PngCompression__ For PNG, it can be the compression level from 0 to 9.
%          A higher value means a smaller size and longer compression time.
%          Default value is 3.
% * __PxmBinary__ For PPM, PGM, or PBM, it can be a binary format flag, 0 or
%          1 . Default value is 1.
%
% The function imwrite saves the image to the specified file. The image format
% is chosen based on the filename extension (see cv.imread for the list of
% extensions). Only 8-bit (or 16-bit in case of PNG, JPEG 2000, and TIFF)
% single-channel or 3-channel (with RGB channel order) images can be saved
% using this function.
%
% See also cv.imread
%
