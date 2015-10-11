%ILLUMINATIONCHANGE  Illumination Change
%
%    dst = cv.illuminationChange(src, mask)
%    dst = cv.illuminationChange(src, mask, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
% * __mask__ Input 8-bit 1 or 3-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __Alpha__ Value ranges between 0-2. default 0.2
% * __Beta__ Value ranges between 0-2. default 0.4
% * __FlipChannels__ whether to flip the order of color channels in inputs
%       `src` and `mask` and output `dst`, between MATLAB's RGB order and
%       OpenCV's BGR (input: RGB->BGR, output: BGR->RGB). default true
%
% Applying an appropriate non-linear transformation to the gradient field
% inside the selection and then integrating back with a Poisson solver,
% modifies locally the apparent illumination of an image.
%
% This is useful to highlight under-exposed foreground objects or to reduce
% specular reflections.
%
