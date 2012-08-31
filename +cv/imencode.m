%IMENCODE  Encodes an image into a memory buffer
%
%    buf = cv.imencode(ext, img)
%    buf = cv.imencode(ext, img, 'OptionName', optionValue, ...)
%
% ## Input
% * __ext__ File extension that defines the output format: '.jpg', '.png'.
% * __img__ Image to be written.
%
% ## Output
% * __buf__ Output buffer of the compressed image.
%
% ## Options
% Format-specific save parameters. The following parameters are currently
% supported
%
% * __JpegQuality__ For JPEG, it can be a quality from 0 to 100 (the
%         higher is the better). Default value is 95.
% * __PngCompression__ For PNG, it can be the compression level from 0 to
%         9. A higher value means a smaller size and longer compression
%         time. Default value is 3.
% * __PxmBinary__ For PPM, PGM, or PBM, it can be a binary format flag, 0
%         or 1. Default value is 1.
%
% The function compresses the image and stores it in the memory buffer
% that is resized to fit the result. See cv.imwrite for the list of
% supported formats and flags description.
%
% See also cv.imdecode cv.imread cv.imwrite
%