%DCTDENOISING  The function implements simple dct-based denoising
%
%    dst = cv.dctDenoising(src)
%    dst = cv.dctDenoising(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ source image (gray or RGB).
%       Internally the function operates on `single` data type.
%
% ## Output
% * __dst__ destination image, same size and type as input `src`.
%
% ## Options
% * __Sigma__ expected noise standard deviation. Default 10.0
% * __BlockSize__ size of block side where DCT is computed. Default 16
%
% See [YSDCT11]. The function is parallelized.
%
% ## References
% [YSDCT11]:
% > Guoshen Yu and Guillermo Sapiro. "DCT image denoising: a simple and
% > effective image denoising algorithm", Image Processing On Line, 1 (2011).
% > http://dx.doi.org/10.5201/ipol.2011.ys-dct
% > http://www.ipol.im/pub/art/2011/ys-dct/
%
% See also: cv.fastNlMeansDenoising
%