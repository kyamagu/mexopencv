%BILATERALTEXTUREFILTER  Applies the bilateral texture filter to an image
%
%     dst = cv.bilateralTextureFilter(src)
%     dst = cv.bilateralTextureFilter(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Source image whose depth is 8-bit `uint8` or 32-bit `single`
%
% ## Output
% * __dst__ Destination image of the same size and type as `src`.
%
% ## Options
% * __FR__ Radius of kernel to be used for filtering. It should be positive
%   integer. default 3
% * __NumIter__ Number of iterations of algorithm, It should be positive
%   integer. default 1
% * __SigmaAlpha__ Controls the sharpness of the weight transition from edges
%   to smooth/texture regions, where a bigger value means sharper transition.
%   When the value is negative, it is automatically calculated. default -1
% * __SigmaAvg__ Range blur parameter for texture blurring. Larger value makes
%   result to be more blurred. When the value is negative, it is automatically
%   calculated as described in the paper. default -1
%
% It performs structure-preserving texture filter. For more details about this
% filter see [Cho2014].
%
% ## References
% [Cho2014]:
% > Hojin Cho, Hyunjoon Lee, Henry Kang, and Seungyong Lee.
% > "Bilateral texture filtering". ACM Transactions on Graphics,
% > 33(4):128:1-128:8, July 2014.
%
% See also: cv.rollingGuidanceFilter, cv.bilateralFilter
%
