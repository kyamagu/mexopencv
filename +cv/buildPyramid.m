%BUILDPYRAMID  Constructs the Gaussian pyramid for an image
%
%    dst = cv.buildPyramid(src)
%    dst = cv.buildPyramid(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image. Check cv.pyrDown for the list of supported types.
%
% ## Output
% * __dst__ Destination vector of `Maxlevel+1` images of the same type as
%       `src`. A cell array of images. `dst{1}` will be the same as `src`.
%       `dst{2}` is the next pyramid layer, a smoothed and down-sized `src`,
%       and so on.
%
% ## Options
% * __MaxLevel__ 0-based index of the last (the smallest) pyramid layer. It
%       must be non-negative. default 5
% * __BorderType__ Pixel extrapolation method, ('Constant' isn't supported).
%       See cv.copyMakeBorder for details. Default 'Default'
%
% The function constructs a vector of images and builds the Gaussian pyramid
% by recursively applying cv.pyrDown to the previously built pyramid layers,
% starting from `dst{1}==src`.
%
% See also: cv.pyrDown, cv.pyrUp
%
