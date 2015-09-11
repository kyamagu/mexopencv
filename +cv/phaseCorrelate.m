%PHASECORRELATE  Detect translational shifts that occur between two images
%
%    pshift = cv.phaseCorrelate(src1, src2)
%    [pshift,response] = cv.phaseCorrelate(src1, src2)
%    [...] = cv.phaseCorrelate(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src1__ First source floating point array (single-channel `single` or
%       `double`).
% * __src2__ Second source floating point array (single-channel `single` or
%       `double`), of same size and type as `src1`.
%
% ## Output
% * __pshift__ detected phase shift (sub-pixel) between the two arrays `[x,y]`
% * __response__ Signal power within the 5x5 centroid around the peak, between
%       0 and 1 (optional).
%
% ## Options
% * __Window__ Floating point array with windowing coefficients to reduce edge
%       effects (optional). Not set by default.
%
% The function is used to detect translational shifts that occur between two
% images.
%
% The operation takes advantage of the Fourier shift theorem for detecting the
% translational shift in the frequency domain. It can be used for fast image
% registration as well as motion estimation. For more information please see
% http://en.wikipedia.org/wiki/Phase_correlation
%
% Calculates the cross-power spectrum of two supplied source arrays. The
% arrays are padded if needed with cv.getOptimalDFTSize.
%
% The function performs the following equations:
%
% * First it applies a Hanning window (see
%   http://en.wikipedia.org/wiki/Hann_function) to each image to remove
%   possible edge effects. This window is cached until the array size changes
%   to speed up processing time.
%
% * Next it computes the forward DFTs of each source array:
%
%        G_a = F{src1}, G_b = F{src2}
%
%    where `F` is the forward DFT.
%
% * It then computes the cross-power spectrum of each frequency domain array:
%
%        R = G_a * G_b^(*) / |G_a * G_b^(*)|
%
% * Next the cross-correlation is converted back into the time domain via the
%   inverse DFT:
%
%        r = F^(-1){R}
%
% * Finally, it computes the peak location and computes a 5x5 weighted
%   centroid around the peak to achieve sub-pixel accuracy.
%
%        (\Delta{x}, \Delta{y}) = weightedCentroid{argmax_(x,y){r}}
%
% * If non-zero, the response parameter is computed as the sum of the elements
%   of `r` within the 5x5 centroid around the peak location. It is normalized
%   to a maximum of 1 (meaning there is a single peak) and will be smaller
%   when there are multiple peaks.
%
% See also: cv.dft, cv.getOptimalDFTSize, cv.idft, cv.mulSpectrums,
%  cv.createHanningWindow, imregcorr
%
