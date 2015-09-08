%BILATERALFILTER  Applies the bilateral filter to an image
%
%    result = cv.bilateralFilter(img)
%    result = cv.bilateralFilter(img, 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Source 8-bit or floating-point, 1-channel or 3-channel image.
%
% ## Output
% * __result__ Destination image of the same size and type as `src`.
%
% ## Options
% * __Diameter__ Diameter of each pixel neighborhood that is used during
%       filtering. If it is non-positive, it is computed from `SigmaSpace`.
%       Default: 7
% * __SigmaColor__ Filter sigma in the color space. A larger value of the
%       parameter means that farther colors within the pixel neighborhood (see
%       `SigmaSpace`) will be mixed together, resulting in larger areas of
%       semi-equal color. Default: 50.0
% * __SigmaSpace__ Filter sigma in the coordinate space. A larger value of the
%       parameter means that farther pixels will influence each other as long
%       as their colors are close enough (see `SigmaColor`). When `Diameter>0`,
%       it specifies the neighborhood size regardless of `SigmaSpace`.
%       Otherwise, `Diameter` is proportional to `SigmaSpace`. Default: 50.0
% * __BorderType__ border mode used to extrapolate pixels outside of the
%       image. See cv.copyMakeBorder. Default: 'Default'
%
% The function applies bilateral filtering to the input image, as described
% in [CVonline]. cv.bilateralFilter can reduce unwanted noise very well while
% keeping edges fairly sharp. However, it is very slow compared to most
% filters.
%
% *Sigma values*: For simplicity, you can set the 2 sigma values to be the
% same. If they are small (`< 10`), the filter will not have much effect,
% whereas if they are large (`> 150`), they will have a very strong effect,
% making the image look "cartoonish".
%
% *Filter size*: Large filters (`Diameter > 5`) are very slow, so it is
% recommended to use `Diameter=5` for real-time applications, and perhaps
% `Diameter=9` for offline applications that need heavy noise filtering.
%
% ## References
% [CVonline]:
% > http://www.dai.ed.ac.uk/CVonline/LOCAL_COPIES/MANDUCHI1/Bilateral_Filtering.html
%
