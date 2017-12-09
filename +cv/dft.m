%DFT  Performs a forward or inverse Discrete Fourier transform of a 1D or 2D floating-point array
%
%     dst = cv.dft(src)
%     dst = cv.dft(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input floating-point array that could be real or complex.
%
% ## Output
% * __dst__ output array whose size and type depends on the flags.
%
% ## Options
% * __Inverse__ performs an inverse 1D or 2D transform instead of the default
%   forward transform. default false
% * __Scale__ scales the result: divide it by the number of array elements.
%   Normally, it is combined with the `Inverse` flag, as it guarantees that
%   the inverse of the inverse will have the correct normalization.
%   default false
% * __Rows__ performs a forward or inverse transform of every individual row
%   of the input matrix; this flag enables you to transform multiple vectors
%   simultaneously and can be used to decrease the overhead (which is sometimes
%   several times larger than the processing itself) to perform 3D and
%   higher-dimensional transformations and so forth. default false
% * __ComplexOutput__ performs a forward transformation of 1D or 2D real
%   array; the result, though being a complex array, has complex-conjugate
%   symmetry (*CCS*, see the function description below for details), and such
%   an array can be packed into a real array of the same size as input, which
%   is the fastest option and which is what the function does by default;
%   however, you may wish to get a full complex array (for simpler spectrum
%   analysis, and so on), pass the flag to enable the function to produce a
%   full-size complex output array. default false
% * __RealOutput__ performs an inverse transformation of a 1D or 2D complex
%   array; the result is normally a complex array of the same size, however,
%   if the input array has conjugate-complex symmetry (for example, it is a
%   result of forward transformation with `ComplexOutput` flag), the output is
%   a real array; while the function itself does not check whether the input
%   is symmetrical or not, you can pass the flag and then the function will
%   assume the symmetry and produce the real output array (note that when the
%   input is packed into a real array and inverse transformation is executed,
%   the function treats the input as a packed complex-conjugate symmetrical
%   array, and the output will also be a real array). default false
% * __ComplexInput__ specifies that input is complex input. If this flag is
%   set, the input must have 2 channels. On the other hand, for backwards
%   compatibility reason, if input has 2 channels, input is already considered
%   complex. default false
% * __NonzeroRows__ when the parameter is not zero, the function assumes that
%   only the first `NonzeroRows` rows of the input array (`Inverse` is not set)
%   or only the first `NonzeroRows` of the output array (`Inverse` is set)
%   contain non-zeros, thus, the function can handle the rest of the rows more
%   efficiently and save some time; this technique is very useful for
%   calculating array cross-correlation or convolution using DFT. default 0
%
% The function cv.dft performs one of the following:
%
% * Forward the Fourier transform of a 1D vector of N elements:
%
%       Y = FN * X
%
%   where
%
%       FN(j,k) = exp(-2*pi * 1i * j * k/N)
%
%   and `1i = sqrt(-1)`
%
% * Inverse the Fourier transform of a 1D vector of N elements:
%
%       X'= inv(FN) * Y = ctranspose(FN) * Y
%       X = (1/N) * X'
%
%   where `ctranspose(F) = transpose(conj(F)) = transpose(real(F) - 1i*imag(F))`
%
% * Forward the 2D Fourier transform of a MxN matrix:
%
%       Y = FM * X * FN
%
% * Inverse the 2D Fourier transform of a MxN matrix:
%
%       X'= ctranspose(FM) * Y * ctranspose(FN)
%       X = (1/(M*N)) * X'
%
% In case of real (single-channel) data, the output spectrum of the forward
% Fourier transform or input spectrum of the inverse Fourier transform can be
% represented in a packed format called *CCS* (complex-conjugate-symmetrical).
% It was borrowed from IPL (Intel Image Processing Library). Here is how 2D
% *CCS* spectrum looks:
%
%     CCS = [
%       ReY(0,0), ReY(0,1), ImY(0,1), ..., ReY(0,N/2-1), ImY(0,N/2-1), ReY(0,N/2)
%       ReY(1,0), ReY(1,1), ImY(1,1), ..., ReY(1,N/2-1), ImY(1,N/2-1), ReY(1,N/2)
%       ImY(1,0), ReY(2,1), ImY(2,1), ..., ReY(2,N/2-1), ImY(2,N/2-1), ImY(1,N/2)
%       ...
%       ReY(M/2-1,0), ReY(M-3,1), ImY(M-3,1), ..., ReY(M-3,N/2-1), ImY(M-3,N/2-1), ReY(M/2-1,N/2)
%       ImY(M/2-1,0), ReY(M-2,1), ImY(M-2,1), ..., ReY(M-2,N/2-1), ImY(M-2,N/2-1), ImY(M/2-1,N/2)
%       ReY(M/2,  0), ReY(M-1,1), ImY(M-1,1), ..., ReY(M-1,N/2-1), ImY(M-1,N/2-1), ReY(M/2,  N/2)
%     ]
%
% In case of 1D transform of a real vector, the output looks like the first
% row of the matrix above.
%
% So, the function chooses an operation mode depending on the flags and size
% of the input array:
%
% * If `Rows` is set or the input array has a single row or single column, the
%   function performs a 1D forward or inverse transform of each row of a
%   matrix when `Rows` is set. Otherwise, it performs a 2D transform.
% * If the input array is real and `Inverse` is not set, the function performs
%   a forward 1D or 2D transform:
%   * When `ComplexOutput` is set, the output is a complex matrix of the same
%     size as input.
%   * When `ComplexOutput` is not set, the output is a real matrix of the same
%     size as input. In case of 2D transform, it uses the packed format as
%     shown above. In case of a single 1D transform, it looks like the first
%     row of the matrix above. In case of multiple 1D transforms (when using
%     the `Rows` flag), each row of the output matrix looks like the first row
%     of the matrix above.
% * If the input array is complex and either `Inverse` or `RealOutput` are not
%   set, the output is a complex array of the same size as input. The function
%   performs a forward or inverse 1D or 2D transform of the whole input array
%   or each row of the input array independently, depending on the flags
%   `Inverse` and `Rows`.
% * When `Inverse` is set and the input array is real, or it is complex but
%   `RealOutput` is set, the output is a real array of the same size as input.
%   The function performs a 1D or 2D inverse transformation of the whole input
%   array or each individual row, depending on the flags `Inverse` and `Rows`.
%
% If `Scale` is set, the scaling is done after the transformation.
%
% Unlike cv.dct, the function supports arrays of arbitrary size. But only
% those arrays are processed efficiently, whose sizes can be factorized in a
% product of small prime numbers (2, 3, and 5 in the current implementation).
% Such an efficient DFT size can be calculated using the cv.getOptimalDFTSize
% method.
%
% Note: cv.idft is equivalent to `cv.dft(..., 'Inverse',true)`.
% Also note that none of cv.dft and cv.idft scales the result by default. So,
% you should pass `Scale=true` to one of cv.dft or cv.idft explicitly to make
% these transforms mutually inverse.
%
% ## Example
%
% The sample below illustrates how to calculate a DFT-based convolution of two
% 2D real arrays:
%
%     function C = convolveDFT(A, B)
%         % calculate the size of DFT transform
%         dftSize = size(A) + size(B) - 1;
%         dftSize(1) = cv.getOptimalDFTSize(dftSize(1));
%         dftSize(2) = cv.getOptimalDFTSize(dftSize(2));
%
%         % allocate temporary buffers and initialize them with 0's
%         tempA = zeros(dftSize, class(A));
%         tempB = zeros(dftSize, class(B));
%
%         % copy A/B to the top-left corners of tempA/tempB respectively
%         tempA(1:size(A,1), 1:size(A,2)) = A;
%         tempB(1:size(B,1), 1:size(B,2)) = B;
%
%         % now transform the padded A & B in-place;
%         % use 'NonzeroRows' hint for faster processing
%         tempA = cv.dft(tempA, 'NonzeroRows',size(A,1));
%         tempB = cv.dft(tempB, 'NonzeroRows',size(B,1));
%
%         % multiply the spectrums;
%         % the function handles packed spectrum representations well
%         C = cv.mulSpectrums(tempA, tempB);
%
%         % the output array size
%         sz = abs(size(A) - size(B)) + 1;
%
%         % transform the product back from the frequency domain.
%         % Even though all the result rows will be non-zero,
%         % you need only the first sz(1) of them
%         C = cv.dft(C, 'Inverse',true, 'Scale',true, 'NonzeroRows',sz(1));
%
%         % now slice the result part from C
%         C = C(1:sz(1), 1:sz(2));
%     end
%
% To optimize this sample, consider the following approaches:
%
% * Since `NonzeroRows ~= 0` is passed to the forward transform calls and
%   since `A` and `B` are copied to the top-left corners of `tempA` and
%   `tempB`, respectively, it is not necessary to clear the whole `tempA` and
%   `tempB`. It is only necessary to clear the `size(tempA,2) - size(A,2)`
%   (`size(tempB,2) - size(B,2)`) rightmost columns of the matrices.
% * This DFT-based convolution does not have to be applied to the whole big
%   arrays, especially if `B` is significantly smaller than `A` or vice versa.
%   Instead, you can calculate convolution by parts. To do this, you need to
%   split the output array `C` into multiple tiles. For each tile, estimate
%   which parts of `A` and `B` are required to calculate convolution in this
%   tile. If the tiles in `C` are too small, the speed will decrease a lot
%   because of repeated work. In the ultimate case, when each tile in `C` is a
%   single pixel, the algorithm becomes equivalent to the naive convolution
%   algorithm. If the tiles are too big, the temporary arrays `tempA` and
%   `tempB` become too big and there is also a slowdown because of bad cache
%   locality. So, there is an optimal tile size somewhere in the middle.
% * If different tiles in `C` can be calculated in parallel and, thus, the
%   convolution is done by parts, the loop can be threaded.
%
% All of the above improvements have been implemented in `cv.matchTemplate`
% and `cv.filter2D`. Therefore, by using them, you can get the performance
% even better than with the above theoretically optimal implementation.
% Though, those two functions actually calculate cross-correlation, not
% convolution, so you need to "flip" the second convolution operand `B`
% vertically and horizontally using cv.flip.
%
% See also: cv.dct, cv.getOptimalDFTSize, cv.mulSpectrums, cv.cartToPolar,
%  cv.magnitude, cv.phase, fft, fft2, ifft, ifft2, fftshift, unwrap
%
