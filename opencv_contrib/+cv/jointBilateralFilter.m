%JOINTBILATERALFILTER  Applies the joint bilateral filter to an image
%
%     dst = cv.jointBilateralFilter(src, joint)
%     dst = cv.jointBilateralFilter(src, joint, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit or floating-point, 1-channel or 3-channel image with
%   the same depth as `joint` image.
% * __joint__ Joint 8-bit or floating-point, 1-channel or 3-channel image.
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
%   `Diameter` is proportional to `SigmaSpace`. default 10.0
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%   image. See cv.copyMakeBorder. default 'Default'
%
% Note that cv.bilateralFilter and cv.jointBilateralFilter use L1 norm to
% compute difference between colors.
%
% See also: cv.bilateralFilter, cv.AdaptiveManifoldFilter.amFilter
%
