%FIND4QUADCORNERSUBPIX  Finds subpixel-accurate positions of the chessboard corners
%
%    [corners,success] = cv.find4QuadCornerSubpix(img, corners)
%    [...] = cv.find4QuadCornerSubpix(img, corners, 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Input single-channel 8-bit image.
% * __corners__ Initial coordinates of the input corners, stored in numeric
%       array (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors
%       `{[x,y], ...}`. Supports single floating-point class.
%
% ## Output
% * __corners__ Output refined coordinates, of the same size and type as the
%       input `corners` (numeric or cell matching the input format).
% * __success__ boolean success value.
%
% ## Options
% * __RegionSize__ region size `[w,h]`. default [3,3]
%
% See also: cv.cornerSubPix
%
