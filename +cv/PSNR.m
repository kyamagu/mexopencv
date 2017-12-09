%PSNR  Computes the Peak Signal-to-Noise Ratio (PSNR) image quality metric
%
%     psnr = cv.PSNR(src1, src2)
%
% ## Input
% * __src1__ first input array (gray or color image), 8-bit integer type.
% * __src2__ second input array of the same size and type as `src1`.
%
% ## Output
% * __psnr__ Computed signal-to-noise ratio
%
% This function calculates the Peak Signal-to-Noise Ratio (PSNR) image quality
% metric in decibels (dB), between two input arrays `src1` and `src2`. Arrays
% must have `uint8` depth.
%
% The PSNR is calculated as follows:
%
%     PSNR = 10 * log10(R^2 / MSE)
%
% where `R` is the maximum integer value of `uint8` depth (255) and `MSE` is
% the mean squared error between the two arrays.
%
% See [PSNR](https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio) for
% more details.
%
% See also: psnr, immse, ssim
%
