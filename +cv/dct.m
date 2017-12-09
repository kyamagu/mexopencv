%DCT  Performs a forward or inverse discrete Cosine transform of 1D or 2D array
%
%     dst = cv.dct(src)
%     dst = cv.dct(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input floating-point single-channel array.
%
% ## Output
% * __dst__ output array of the same size and type as `src`.
%
% ## Options
% * __Inverse__ performs an inverse 1D or 2D transform instead of the default
%   forward transform. default false
% * __Rows__ performs a forward or inverse transform of every individual row
%   of the input matrix. This flag enables you to transform multiple vectors
%   simultaneously and can be used to decrease the overhead (which is sometimes
%   several times larger than the processing itself) to perform 3D and
%   higher-dimensional transforms and so forth. default false
%
% The function cv.dct performs a forward or inverse discrete Cosine
% transform (DCT) of a 1D or 2D floating-point array:
%
% - Forward Cosine transform of a 1D vector of N elements:
%
%       Y = CN * X
%
%   where
%
%       CN(j,k) = sqrt(alpha_j/N) * cos((pi*(2k+1)*j)/2N)
%
%   and `alpha_0=1`, `alpha_j=2` for `j>0`.
%
% - Inverse Cosine transform of a 1D vector of N elements:
%
%       X = inv(CN) * Y = transpose(CN) * Y
%
%   (since `CN` is an orthogonal matrix, `CN * transpose(CN) = I`)
%
% - Forward 2D Cosine transform of MxN matrix:
%
%       Y = CN * X * transpose(CN)
%
% - Inverse 2D Cosine transform of MxN matrix:
%
%       X =  transpose(CN) * X * CN
%
% The function chooses the mode of operation by looking at the transformation
% flags and size of the input array:
%
% - If `Inverse = true`, the function does a forward 1D or 2D transform.
%   Otherwise, it is an inverse 1D or 2D transform.
% - If `Rows = true`, the function performs a 1D transform of each row.
% - If the array is a single column or a single row, the function performs a
%   1D transform.
% - If none of the above is true, the function performs a 2D transform.
%
% Note: Currently cv.dct supports even-size arrays (2, 4, 6, etc.). For data
% analysis and approximation, you can pad the array when necessary. Also, the
% function performance depends very much, and not monotonically, on the array
% size (see cv.getOptimalDFTSize). In the current implementation, DCT of a
% vector of size `N` is calculated via DFT of a vector of size `N/2`. Thus,
% the optimal DCT size `N1 >= N` can be calculated as:
%
%     function N1 = getOptimalDCTSize(N)
%         N1 = 2 * cv.getOptimalDFTSize(fix((N+1)/2));
%     end
%
% Note: cv.idct is equivalent to `cv.dct(..., 'Inverse',true)`.
%
% See also: cv.dft, cv.getOptimalDFTSize, dct, dct2, idct, idct2
%
