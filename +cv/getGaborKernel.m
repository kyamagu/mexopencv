%GETGABORKERNEL  Returns Gabor filter coefficients
%
%    kernel = cv.getGaborKernel('OptionName',optionValue, ...)
%
% ## Output
% * __kernel__ output kernel of the specified size and type.
%
% ## Options
% * __KSize__ Size of the filter returned `[w,h]`. default [21,21]
% * __Sigma__ Standard deviation of the gaussian envelope. default 5.0
% * __Theta__ Orientation of the normal to the parallel stripes of a Gabor
%       function. default pi/4
% * __Lambda__ Wavelength of the sinusoidal factor. default 10.0
% * __Gamma__ Spatial aspect ratio. default 0.75
% * __Psi__ Phase offset. default pi/2
% * __KType__ Type of filter coefficients. It can be `single` or `double`.
%       default `double`.
%
% For more details about gabor filter equations and parameters, see:
% http://en.wikipedia.org/wiki/Gabor_filter
%
% ## Example
% Try the <a href="matlab:edit('gabor_filter_gui')">gabor_filter_gui.m</a>
% sample file to interact with the various parameters of the Gabor filter
% and visualize the result.
%
