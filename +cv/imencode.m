%IMENCODE  Encodes an image into a memory buffer
%
%    buf = cv.imencode(ext, img)
%    buf = cv.imencode(ext, img, 'OptionName', optionValue, ...)
%
% ## Input
% * __ext__ File extension that defines the output format. For example:
%       '.bmp', '.jpg', '.png', '.tif', etc...
% * __img__ Image to be encoded.
%
% ## Output
% * __buf__ Output buffer of the compressed image. A row vector of type
%       `uint8` that contains encoded image as an array of bytes.
%       If the image cannot be encoded, the function throws an error.
%
% ## Options
% * __FlipChannels__ in case the input is color image, flips the color order
%       from MATLAB's RGB/RGBA to OpenCV's BGR/BGRA order. default true
%
% The following format-specific save parameters are currently supported:
%
% * __JpegQuality__ For JPEG, it can be a quality from 0 to 100 (the higher is
%       the better). Default value is 95.
% * __JpegProgressive__ Enable JPEG features, 0 or 1, default is false.
% * __JpegOptimize__ Enable JPEG features, 0 or 1, default is false.
% * __JpegResetInterval__ JPEG restart interval, 0 - 65535,
%       default is 0 (no restart).
% * __JpegLumaQuality__ Separate luma quality level, 0 - 100,
%       default is 0 (don't use).
% * __JpegChromaQuality__ Separate chroma quality level, 0 - 100,
%       default is 0 (don't use).
% * __PngCompression__ For PNG, it can be the compression level from 0 to 9.
%       A higher value means a smaller size and longer compression time.
%       Default value is 3.
% * __PngStrategy__ For PNG; used to tune the compression algorithm. These
%       flags will be modify the way of PNG image compression and will be
%       passed to the underlying zlib processing stage. The strategy parameter
%       only affects the compression ratio but not the correctness of the
%       compressed output even if it is not set appropriately. One of:
%       * __Default__ (default) Use this value for normal data.
%       * __Filtered__ Use this value for data produced by a filter (or
%             predictor). Filtered data consists mostly of small values with a
%             somewhat random distribution. In this case, the compression
%             algorithm is tuned to compress them better. The effect of
%             `Filtered` is to force more Huffman coding and less string
%             matching; it is somewhat intermediate between `Default` and
%             `HuffmanOnly`.
%       * __HuffmanOnly__ Use this value to force Huffman encoding only
%             (no string match).
%       * __RLE__ Use this value to limit match distances to one (run-length
%             encoding). `RLE` is designed to be almost as fast as
%             `HuffmanOnly`, but give better compression for PNG image data.
%       * __Fixed__ Using this value prevents the use of dynamic Huffman
%             codes, allowing for a simpler decoder for special applications.
% * __PngBilevel__ Binary level PNG, 0 or 1, controls packing of pixels per
%       bytes. If false, PNG files pack pixels of bit-depths 1, 2, and 4 into
%       bytes as small as possible. default is false.
% * __PxmBinary__ For PPM, PGM, or PBM, it can be a binary format flag, 0 or 1,
%       to specify ASCII or binary encoding. default is true.
% * __WebpQuality__ For WEBP, it can be a quality from 1 to 100 (the higher is
%       the better). By default (without any parameter) and for quality above
%       100 the lossless compression is used.
%
% For advanced uses, you can directly pass a vector of paramters:
%
% * __Params__ Format-specific save parameters encoded as pairs:
%       `[paramId_1, paramValue_1, paramId_2, paramValue_2, ...]`.
%
% The function compresses the image and stores it in the memory buffer. See
% cv.imwrite for the list of supported formats and flags description.
%
% See also: cv.imdecode, cv.imwrite
%
