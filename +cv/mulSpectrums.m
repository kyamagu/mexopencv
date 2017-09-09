%MULSPECTRUMS  Performs the per-element multiplication of two Fourier spectrums
%
%     c = cv.mulSpectrums(a, b)
%     c = cv.mulSpectrums(a, b, 'OptionName',optionValue, ...)
%
% ## Input
% * __a__ first input array.
% * __b__ second input array of the same size and type as `a`.
%
% ## Output
% * __c__ output array of the same size and type as `a`.
%
% ## Options
% * __Rows__ flag which indicates that each row of `a` and `b` is an
%   independent 1D Fourier spectrum. default false
% * __ConjB__ optional flag that conjugates the second input array before the
%   multiplication (true) or not (false). default false
%
% The function cv.mulSpectrums performs the per-element multiplication of the
% two CCS-packed or complex matrices that are results of a real or complex
% Fourier transform.
%
% The function, together with cv.dft and cv.idft, may be used to calculate
% convolution (pass `ConjB=false`) or correlation (pass `ConjB=true`) of two
% arrays rapidly. When the arrays are complex, they are simply multiplied
% (per element) with an optional conjugation of the second-array elements.
% When the arrays are real, they are assumed to be CCS-packed (see cv.dft for
% details).
%
% See also: cv.dft, conj, conv, filter, fftfilt
%
