%BALANCEWHITE  The function implements different algorithm of automatic white balance
%
%    dst = cv.balanceWhite(src)
%    dst = cv.balanceWhite(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image (RGB or gray), integer or floating point image.
%
% ## Output
% * __dst__ output image, same size and type as input `src`.
%
% ## Options
% * __Type__ various white balance algorithms. One of:
%       * __Simple__ (default) perform smart histogram adjustments (ignoring
%             4% pixels with minimal and maximal values) for each channel.
%       * __GrayWorld__ currently not implemented!
% * __InputMin__ minimum value in the input image, default 0.0
% * __InputMax__ maximum value in the input image, default 255.0
% * __OutputMin__ minimum value in the output image, default 0.0
% * __OutputMax__ maximum value in the output image, default 255.0
%
% The function tries to map image's white color to perceptual white (this can
% be violated due to specific illumination or camera settings).
%
% See also: cv.cvtColor, cv.equalizeHist
%
