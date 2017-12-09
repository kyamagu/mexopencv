%ROLLINGGUIDANCEFILTER  Applies the rolling guidance filter to an image
%
%     dst = cv.rollingGuidanceFilter(src)
%     dst = cv.rollingGuidanceFilter(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit or floating-point, 1-channel or 3-channel image.
%
% ## Output
% * __dst__ Destination image of the same size and type as `src`.
%
% ## Options
% * __Diameter__ Diameter of each pixel neighborhood that is used during
%   filtering. If it is non-positive, it is computed from `SigmaSpace`.
%   default -1
% * __SigmaColor__ Filter sigma in the color space. A larger value of the
%   parameter means that farther colors within the pixel neighborhood (see
%   `SigmaSpace`) will be mixed together, resulting in larger areas of
%   semi-equal color. default 25.0
% * __SigmaSpace__ Filter sigma in the coordinate space. A larger value of the
%   parameter means that farther pixels will influence each other as long as
%   their colors are close enough (see `SigmaColor`). When `Diameter>0`, it
%   specifies the neighborhood size regardless of `SigmaSpace`. Otherwise,
%   `Diameter` is proportional to `SigmaSpace`. default 3.0
% * __NumIter__ Number of iterations of joint edge-preserving filtering
%   applied on the source image. default 4
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%   image. See cv.copyMakeBorder. default 'Default'
%
% For more details, please see [zhang2014rolling].
%
% Note that cv.rollingGuidanceFilter uses cv.jointBilateralFilter as the
% edge-preserving filter.
%
% ## References
% [zhang2014rolling]:
% > Qi Zhang, Xiaoyong Shen, Li Xu, and Jiaya Jia. "Rolling guidance filter".
% > In Computer Vision-ECCV 2014, pages 815-830. Springer, 2014.
%
% See also: cv.jointBilateralFilter, cv.bilateralFilter,
%  cv.AdaptiveManifoldFilter.amFilter
%
